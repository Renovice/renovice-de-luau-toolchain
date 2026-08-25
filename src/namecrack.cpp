// Token-recombination attack on unresolved 32-bit name hashes.
// Engine identifiers are compounds of a small token vocabulary (Get/Set/Is/Overguard/Health/...).
// FNV-1a is incremental, so we hash TokenA once and continue into TokenB — no string rebuilding.
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <unordered_set>
static const uint32_t SEED = 0x7E5AF8E9u;
static inline uint32_t step(uint32_t h, const std::string& s) {
    for (unsigned char c : s) h = (h ^ (uint32_t)c) * 0x01000193u;
    return h;
}
static inline uint32_t fin(uint32_t h) { h = ~h; return (h << 17) | (h >> 15); }

int main(int argc, char** argv) {
    if (argc < 3) { std::fprintf(stderr, "usage: namecrack <verified.tsv> <unresolved.txt> [out.tsv]\n"); return 1; }
    // known names -> token vocabulary
    std::vector<std::string> names;
    { std::ifstream f(argv[1]); std::string ln;
      while (std::getline(f, ln)) { size_t t = ln.find('\t'); if (t != std::string::npos) names.push_back(ln.substr(t + 1)); } }
    std::set<std::string> tokset;
    for (const std::string& n : names) {
        std::string cur;
        for (size_t i = 0; i < n.size(); ++i) {
            char c = n[i];
            bool boundary = (c == '_') || (i && std::isupper((unsigned char)c) && !std::isupper((unsigned char)n[i-1]));
            if (boundary) { if (cur.size() >= 2) tokset.insert(cur); cur.clear(); if (c == '_') continue; }
            cur += c;
        }
        if (cur.size() >= 2) tokset.insert(cur);
    }
    std::vector<std::string> toks(tokset.begin(), tokset.end());
    // unresolved target hashes
    std::unordered_set<uint32_t> want;
    std::vector<uint64_t> bloom(1u<<20, 0);   // 2^26 bits
    { std::ifstream f(argv[2]); std::string ln;
      while (std::getline(f, ln)) if (ln.size() >= 8) { uint32_t h=(uint32_t)std::strtoul(ln.c_str(), nullptr, 16);
          want.insert(h); bloom[(h>>6)&((1u<<20)-1)] |= (1ull<<(h&63)); } }
    auto maybe = [&](uint32_t h){ return (bloom[(h>>6)&((1u<<20)-1)] >> (h&63)) & 1ull; };
    std::fprintf(stderr, "tokens=%zu targets=%zu\n", toks.size(), want.size());
    std::map<uint32_t, std::string> hits;
    // 1-token and prefix+token
    static const char* PRE[] = {"Get","Set","Is","On","Has","Can","Add","Remove","Update","Create","Destroy",
                                "Init","Start","Stop","Enable","Disable","Try","Do","Make","Find","Check","Apply",
                                "Play","Send","Show","Hide","Reset","Clear","Load","Save","Spawn","Kill","m","g",""};
    for (const std::string& a : toks) {
        uint32_t ha = step(SEED, a);
        { uint32_t h=fin(ha); if (maybe(h) && want.count(h)) hits[h]=a; }
        for (const char* p : PRE) {
            std::string pa = std::string(p) + a;
            uint32_t h = fin(step(SEED, pa));
            if (maybe(h) && want.count(h)) hits[h] = pa;
        }
    }
    std::fprintf(stderr, "after 1-token/prefix: %zu\n", hits.size());
    // 2-token compounds (incremental)
    for (const std::string& a : toks) {
        uint32_t ha = step(SEED, a);
        for (const std::string& b : toks) {
            uint32_t h = fin(step(ha, b));
            if (maybe(h) && want.count(h) && !hits.count(h)) hits[h] = a + b;
        }
    }
    std::fprintf(stderr, "after 2-token: %zu\n", hits.size());
    // prefix + 2-token
    for (const char* p : PRE) {
        uint32_t hp = step(SEED, p);
        for (const std::string& a : toks) {
            uint32_t ha = step(hp, a);
            for (const std::string& b : toks) {
                uint32_t h = fin(step(ha, b));
                if (want.count(h) && !hits.count(h)) hits[h] = std::string(p) + a + b;
            }
        }
    }
    std::fprintf(stderr, "after prefix+2-token: %zu\n", hits.size());
    if (argc >= 4) { std::ofstream o(argv[3]);
        for (auto& kv : hits) { char b[16]; std::snprintf(b, sizeof b, "%08x\t", kv.first); o << b << kv.second << "\n"; } }
    std::printf("CRACKED %zu / %zu unresolved hashes\n", hits.size(), want.size());
    return 0;
}
