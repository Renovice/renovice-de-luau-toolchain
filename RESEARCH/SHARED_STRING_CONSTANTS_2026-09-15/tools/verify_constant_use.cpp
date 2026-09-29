#include <algorithm>
#include <fstream>
#include <iostream>
#include <iterator>
#include <utility>
#include "transcode.h"

static int failures = 0;
static void check(bool ok, const char* name) {
    std::cout << (ok ? "PASS " : "FAIL ") << name << '\n';
    if (!ok) ++failures;
}
static unsigned opcode(const char* name) {
    for (int i=0; i<luau::NOPS; ++i) if (std::string(luau::OPS[i])==name) return i;
    throw std::runtime_error("fixture opcode missing");
}
static luau::Insn instruction(const char* name, unsigned key=0) {
    luau::Insn x; x.op=opcode(name); x.A=0; x.B=key&255; x.C=key>>8;
    x.D=key; x.has_aux=luau::op_has_aux(x.op); x.aux=key; return x;
}
static void fixture(const char* name, const char* value_op, bool table_template=false,
                    bool table_values=false, bool hashed_field=false) {
    luau::Module m; m.strings={"table","concat","GetBuffNotifications"};
    luau::Proto p; p.mx=3;
    for (unsigned i=1; i<=3; ++i) { luau::Const c; c.tag=luau::C_STR; c.u=i; p.consts.push_back(c); }
    luau::Const import; import.tag=luau::C_IMPORT; import.u=(2u<<30)|(0u<<20)|(1u<<10);
    p.consts.push_back(import);
    auto read=instruction("GETIMPORT",3); read.aux=import.u; p.insns.push_back(read);
    auto method=instruction("NAMECALL",2); p.insns.push_back(method);
    if (value_op) {
        auto use=instruction(value_op,0);
        if (std::string(value_op)=="ANDK" || std::string(value_op)=="ORK") use.C=0;
        p.insns.push_back(use);
    }
    if (hashed_field) p.insns.push_back(instruction("GETTABLEKS",0));
    if (table_template || table_values) {
        luau::Const c;
        c.tag=table_values ? luau::C_TABLEK : luau::C_TABLE;
        if (table_values) c.items={{1,0}}; else c.keys={0};
        p.consts.push_back(c);
    }
    std::vector<std::string> pool; std::map<std::string,int> ids;
    std::map<uint32_t,uint32_t> names, imports;
    auto out=tc::transcode_consts(m,p,pool,ids,names,imports,{},hashed_field?std::set<std::string>{"table"}:std::set<std::string>{});
    bool value_required=value_op || table_template || table_values;
    bool ok=value_required ? (out[0].tag==3 && names.count(0)==1 && out[names.at(0)].tag==1)
                           : (out[0].tag==1 && names.count(0)==0);
    if (value_required) ok=ok && out[0].idx>=1 && pool.at(out[0].idx-1)=="table"
        && ((imports.at(import.u)>>20)&1023)==names.at(0);
    check(ok,name);
}

static void audit(const char* path) {
    std::ifstream file(path,std::ios::binary); if (!file) throw std::runtime_error("artifact missing");
    std::string bytes((std::istreambuf_iterator<char>(file)),{});
    auto m=de::walk(bytes); unsigned bad=0, loads=0;
    for (const auto& p:m.protos) for (size_t pos=0;pos<p.code.size();) {
        unsigned op=(unsigned char)p.code[pos];
        if (op==0x4e) {
            ++loads; unsigned k=(unsigned char)p.code[pos+2]|((unsigned char)p.code[pos+3]<<8);
            if (k>=p.consts.size()) throw std::runtime_error("LOADK index invalid");
            const auto& c=p.consts[k];
            if (c.tag==1 && c.raw.size()==4) { uint32_t payload=0; std::memcpy(&payload,c.raw.data(),4);
                if (payload>1) { ++bad; std::cout<<"HASH_IN_VALUE_LOAD proto="<<(&p-m.protos.data())<<" key="<<k<<'\n'; }
            }
        }
        pos+=tc::is_de_width8(op)?8:4;
    }
    std::cout<<"VALUE_LOAD_AUDIT loads="<<loads<<" bad="<<bad<<'\n';
    check(bad==0,"actual DE artifact has no nonboolean name hash in LOADK value positions");
}
int main(int argc,char** argv) {
    fixture("import root + literal LOADK","LOADK");
    fixture("import root + literal LOADKX","LOADKX");
    fixture("import root + stored type comparison","JUMPXEQKS");
    fixture("import root + constant fastcall argument","FASTCALL2K");
    fixture("import root + ANDK string result","ANDK");
    fixture("import root + ORK string result","ORK");
    fixture("import root + table template key",nullptr,true);
    fixture("import root + table template value",nullptr,false,true);
    fixture("hashed field + literal LOADK","LOADK",false,false,true);
    fixture("name-only import remains hashed",nullptr);
    if (argc>1) audit(argv[1]);
    std::cout<<"SHARED_CONSTANT_TEST failures="<<failures<<'\n'; return failures ? 1:0;
}
