using System.Collections.Concurrent;
using System.Diagnostics;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

namespace Renovice.AbilityBehavior;

internal static partial class Program
{
    private const string CatalogFormat = "RENOVICE_ABILITY_BEHAVIOR_CATALOG_V1";
    private const string ModuleFormat = "RENOVICE_ABILITY_BEHAVIOR_MODULE_V1";
    private const ulong BodyKeyBasis = 1469598103934665603UL;
    private const ulong BodyKeyPrime = 1099511628211UL;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
        WriteIndented = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
    };

    private sealed record Options(
        string Command,
        string? Catalog,
        string? Toolchain,
        string? SemanticSdk,
        string? OutputDirectory,
        int Jobs,
        bool Reuse);

    private sealed record AbilityIdentity(
        string Warframe,
        string WarframeAssetPath,
        int Slot,
        string Name,
        string AbilityIdentifier,
        string AbilityAssetPath,
        string ModulePath,
        string BodyKey,
        string EntryFunction,
        string StockBytecodePath);

    private sealed record NameRow(
        int Prototype,
        int Web,
        string Canonical,
        string Readable,
        string Confidence,
        string Evidence);

    private sealed record ClosureRow(
        int ParentPrototype,
        int Instruction,
        string Opcode,
        int DestinationRegister,
        string OperandNamespace,
        int OperandIndex,
        int TargetPrototype,
        int TargetParameters,
        int TargetUpvalues,
        int TargetMaxStack,
        int CaptureCount,
        string Captures,
        string Status);

    private sealed record Callsite(
        string Id,
        int Prototype,
        int Block,
        int Instruction,
        int SourceOccurrence,
        int EffectOrder,
        string Kind,
        string Name,
        string? NameHash,
        int? ReceiverWeb,
        string? ReceiverType,
        string? ReceiverTypeConfidence,
        string? ReceiverTypeEvidence,
        IReadOnlyList<int> ArgumentWebs,
        int ExplicitArgumentCount,
        bool OpenArguments,
        IReadOnlyList<int> ResultWebs,
        int ResultCount,
        bool OpenResults,
        string? Descriptor,
        string? ContractConfidence,
        string? ContractStatus,
        string? ContractEvidence,
        string? Parameters,
        string? Returns,
        string ContractMatch,
        int ReadableLine,
        int ReadableColumn,
        IReadOnlyList<string> LexicalFamilies);

    private sealed record ExportBinding(
        string ExportedName,
        string ReadableName,
        int RootPrototype,
        int RootWeb,
        string RootCanonical,
        string Confidence,
        string Evidence,
        string RoleHint,
        int? TargetPrototype,
        int? DefinitionLine,
        string TargetResolution,
        IReadOnlyList<string> DirectCallsiteIds);

    private sealed record AbilityEntryBinding(
        string Warframe,
        string WarframeAssetPath,
        int Slot,
        string Name,
        string AbilityIdentifier,
        string AbilityAssetPath,
        string EntryFunction,
        string Status,
        int? EntryPrototype,
        IReadOnlyList<string> DirectCallsiteIds);

    private sealed record CleanupPair(
        string Forward,
        string Reverse,
        string Pattern,
        string EvidenceBoundary,
        IReadOnlyList<string> ForwardCallsites,
        IReadOnlyList<string> ReverseCallsites);

    private sealed record ArtifactRecord(string File, long Bytes, string Sha256);

    private sealed record InputRecord(
        string BodyKey,
        string BytecodeSha256,
        string DecompilerSha256,
        string SemanticSdkSha256,
        IReadOnlyDictionary<string, ArtifactRecord> Artifacts);

    private sealed record ModuleCounts(
        int Abilities,
        int Exports,
        int ResolvedExportPrototypes,
        int Callsites,
        int RegisteredCallsites,
        int ConfirmedCallsites,
        int CatalogOnlyCallsites,
        int UnregisteredCallsites,
        int AmbiguousCallsites,
        int ObservedMismatchCallsites,
        int LexicalSignalFamilies,
        int CleanupPairCandidates);

    private sealed record ModuleBehavior(
        string Format,
        int SchemaVersion,
        string Status,
        string BodyKey,
        string ModulePath,
        ArtifactRecord StockBytecode,
        ArtifactRecord Decompiler,
        ArtifactRecord SemanticSdk,
        IReadOnlyDictionary<string, ArtifactRecord> GeneratedArtifacts,
        string EvidenceBoundary,
        ModuleCounts Counts,
        IReadOnlyList<AbilityEntryBinding> Abilities,
        IReadOnlyList<ExportBinding> Exports,
        IReadOnlyList<Callsite> Callsites,
        IReadOnlyDictionary<string, IReadOnlyList<string>> LexicalSignalIndex,
        IReadOnlyList<CleanupPair> CleanupPairCandidates,
        IReadOnlyList<string> Rejections);

    private sealed record ModuleIndex(
        string BodyKey,
        string ModulePath,
        string Status,
        string BehaviorFile,
        string BehaviorSha256,
        int AbilityCount,
        int ExportCount,
        int ResolvedExportPrototypes,
        int CallsiteCount,
        int ConfirmedCallsites,
        int CatalogOnlyCallsites,
        int UnregisteredCallsites,
        int RejectionCount);

    private sealed record CatalogCounts(
        int Warframes,
        int Abilities,
        int UniqueModules,
        int VerifiedModules,
        int RejectedModules,
        int VerifiedEntryBindings,
        int RejectedEntryBindings,
        long Callsites,
        long RegisteredCallsites,
        long ConfirmedCallsites,
        long CatalogOnlyCallsites,
        long UnregisteredCallsites,
        long AmbiguousCallsites,
        long ObservedMismatchCallsites,
        long ExactExports,
        long ResolvedExportPrototypes);

    private sealed record RootInputs(
        ArtifactRecord AbilityCatalog,
        ArtifactRecord Decompiler,
        ArtifactRecord SemanticSdk);

    private sealed record RootCatalog(
        string Format,
        int SchemaVersion,
        string Status,
        string EvidenceBoundary,
        RootInputs Inputs,
        CatalogCounts Counts,
        IReadOnlyList<AbilityEntryBindingIndex> Abilities,
        IReadOnlyList<ModuleIndex> Modules,
        string ApiUsageFile,
        string AbilityIndexFile);

    private sealed record AbilityEntryBindingIndex(
        string Warframe,
        int Slot,
        string Name,
        string AbilityIdentifier,
        string AbilityAssetPath,
        string ModulePath,
        string BodyKey,
        string EntryFunction,
        string Status,
        int? EntryPrototype,
        string BehaviorFile);

    private sealed record ProcessResult(int ExitCode, string StandardOutput, string StandardError);

    private sealed record ModuleBuildResult(
        ModuleBehavior Behavior,
        ModuleIndex Index,
        IReadOnlyList<AbilityEntryBindingIndex> AbilityIndex);

    public static async Task<int> Main(string[] args)
    {
        try
        {
            Options options = ParseOptions(args);
            if (options.Command == "self-test")
            {
                return RunSelfTest();
            }
            if (options.Command != "build")
            {
                Usage();
                return 2;
            }

            string catalogPath = RequiredPath(options.Catalog, "--catalog");
            string toolchain = RequiredDirectory(options.Toolchain, "--toolchain");
            string semanticSdk = RequiredPath(options.SemanticSdk, "--semantic-sdk");
            string outputDirectory = RequiredOutputDirectory(options.OutputDirectory, "--output-dir");
            return await BuildCatalogAsync(
                catalogPath,
                toolchain,
                semanticSdk,
                outputDirectory,
                options.Jobs,
                options.Reuse);
        }
        catch (Exception exception)
        {
            Console.Error.WriteLine($"ABILITY BEHAVIOR FAIL {exception.Message}");
            return 1;
        }
    }

    private static Options ParseOptions(string[] args)
    {
        string command = args.Length == 0 ? string.Empty : args[0];
        string? Value(string name)
        {
            for (int index = 1; index + 1 < args.Length; ++index)
            {
                if (string.Equals(args[index], name, StringComparison.Ordinal))
                {
                    return args[index + 1];
                }
            }
            return null;
        }

        int jobs = 2;
        string? jobsText = Value("--jobs");
        if (jobsText is not null
            && (!int.TryParse(jobsText, NumberStyles.None, CultureInfo.InvariantCulture, out jobs)
                || jobs < 1 || jobs > 8))
        {
            throw new ArgumentException("--jobs must be an integer from 1 through 8");
        }

        return new Options(
            command,
            Value("--catalog"),
            Value("--toolchain"),
            Value("--semantic-sdk"),
            Value("--output-dir"),
            jobs,
            args.Contains("--reuse", StringComparer.Ordinal));
    }

    private static void Usage()
    {
        Console.WriteLine(
            "RENOVICE ability behavior catalog\n\n"
            + "Commands:\n"
            + "  self-test\n"
            + "  build --catalog ability-catalog.json --toolchain PATH "
            + "--semantic-sdk symbols.tsv --output-dir PATH [--jobs 1..8] [--reuse]");
    }

    private static string RequiredPath(string? value, string option)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException($"{option} is required");
        }
        string path = Path.GetFullPath(value);
        if (!File.Exists(path))
        {
            throw new FileNotFoundException($"{option} file is missing", path);
        }
        return path;
    }

    private static string RequiredDirectory(string? value, string option)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException($"{option} is required");
        }
        string path = Path.GetFullPath(value);
        if (!Directory.Exists(path))
        {
            throw new DirectoryNotFoundException($"{option} directory is missing: {path}");
        }
        return path;
    }

    private static string RequiredOutputDirectory(string? value, string option)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException($"{option} is required");
        }
        string path = Path.GetFullPath(value);
        Directory.CreateDirectory(path);
        return path;
    }

    private static async Task<int> BuildCatalogAsync(
        string catalogPath,
        string toolchain,
        string semanticSdk,
        string outputDirectory,
        int jobs,
        bool reuse)
    {
        string decompiler = Path.Combine(toolchain, "bin", "derecomp.exe");
        if (!File.Exists(decompiler))
        {
            throw new FileNotFoundException("Certified decompiler is missing", decompiler);
        }

        List<AbilityIdentity> abilities = LoadAbilities(catalogPath);
        if (abilities.Count == 0)
        {
            throw new InvalidDataException("Ability catalog contains no abilities");
        }

        string catalogHash = Sha256File(catalogPath);
        string decompilerHash = Sha256File(decompiler);
        string sdkHash = Sha256File(semanticSdk);
        string moduleRoot = Path.Combine(outputDirectory, "modules");
        Directory.CreateDirectory(moduleRoot);

        var groups = abilities
            .GroupBy(ability => ability.BodyKey, StringComparer.OrdinalIgnoreCase)
            .OrderBy(group => group.Key, StringComparer.Ordinal)
            .ToArray();
        var results = new ConcurrentDictionary<string, ModuleBuildResult>(StringComparer.Ordinal);
        int completed = 0;

        await Parallel.ForEachAsync(
            groups,
            new ParallelOptions { MaxDegreeOfParallelism = jobs },
            async (group, cancellationToken) =>
            {
                ModuleBuildResult result = await BuildModuleAsync(
                    group.Key.ToLowerInvariant(),
                    group.OrderBy(item => item.Warframe, StringComparer.Ordinal)
                        .ThenBy(item => item.Slot)
                        .ToArray(),
                    decompiler,
                    decompilerHash,
                    semanticSdk,
                    sdkHash,
                    moduleRoot,
                    reuse,
                    cancellationToken);
                results[group.Key.ToLowerInvariant()] = result;
                int current = Interlocked.Increment(ref completed);
                Console.WriteLine(
                    $"ABILITY BEHAVIOR MODULE {current}/{groups.Length} "
                    + $"key={group.Key.ToLowerInvariant()} status={result.Behavior.Status} "
                    + $"calls={result.Behavior.Counts.Callsites} exports={result.Behavior.Counts.Exports}");
            });

        ModuleBuildResult[] ordered = groups
            .Select(group => results[group.Key.ToLowerInvariant()])
            .ToArray();
        ModuleIndex[] moduleIndex = ordered.Select(result => result.Index).ToArray();
        AbilityEntryBindingIndex[] abilityIndex = ordered
            .SelectMany(result => result.AbilityIndex)
            .OrderBy(item => item.Warframe, StringComparer.Ordinal)
            .ThenBy(item => item.Slot)
            .ThenBy(item => item.AbilityIdentifier, StringComparer.Ordinal)
            .ToArray();

        WriteAbilityIndex(Path.Combine(outputDirectory, "ability-index.tsv"), abilityIndex);
        WriteApiUsage(Path.Combine(outputDirectory, "api-usage.tsv"), ordered);

        int verifiedModules = moduleIndex.Count(item => item.Status == "VERIFIED");
        int verifiedEntries = abilityIndex.Count(item => item.Status == "VERIFIED");
        var root = new RootCatalog(
            CatalogFormat,
            1,
            verifiedModules == moduleIndex.Length && verifiedEntries == abilityIndex.Length
                ? "VERIFIED"
                : "REJECTED_INCOMPLETE",
            "Exact body-key, verified Semantic IR render, exact export evidence, and renderer-identity entry binding. "
                + "Lexical signal families and cleanup pairs are discovery hints, not gameplay contracts. "
                + "Direct call lists exclude unproven transitive helper execution.",
            new RootInputs(
                Artifact(catalogPath, outputDirectory),
                Artifact(decompiler, outputDirectory),
                Artifact(semanticSdk, outputDirectory)),
            new CatalogCounts(
                abilityIndex.Select(item => item.Warframe).Distinct(StringComparer.Ordinal).Count(),
                abilityIndex.Length,
                moduleIndex.Length,
                verifiedModules,
                moduleIndex.Length - verifiedModules,
                verifiedEntries,
                abilityIndex.Length - verifiedEntries,
                moduleIndex.Sum(item => (long)item.CallsiteCount),
                ordered.Sum(item => (long)item.Behavior.Counts.RegisteredCallsites),
                moduleIndex.Sum(item => (long)item.ConfirmedCallsites),
                moduleIndex.Sum(item => (long)item.CatalogOnlyCallsites),
                moduleIndex.Sum(item => (long)item.UnregisteredCallsites),
                ordered.Sum(item => (long)item.Behavior.Counts.AmbiguousCallsites),
                ordered.Sum(item => (long)item.Behavior.Counts.ObservedMismatchCallsites),
                moduleIndex.Sum(item => (long)item.ExportCount),
                moduleIndex.Sum(item => (long)item.ResolvedExportPrototypes)),
            abilityIndex,
            moduleIndex,
            "api-usage.tsv",
            "ability-index.tsv");

        string rootPath = Path.Combine(outputDirectory, "ability-behavior-catalog.json");
        WriteJsonAtomic(rootPath, root);
        string rootHash = Sha256File(rootPath);
        Console.WriteLine(
            $"ABILITY BEHAVIOR CATALOG {(root.Status == "VERIFIED" ? "PASS" : "FAIL")} "
            + $"warframes={root.Counts.Warframes} abilities={root.Counts.Abilities} "
            + $"modules={root.Counts.UniqueModules} verified_modules={root.Counts.VerifiedModules} "
            + $"entry_bindings={root.Counts.VerifiedEntryBindings}/{root.Counts.Abilities} "
            + $"callsites={root.Counts.Callsites} confirmed={root.Counts.ConfirmedCallsites} "
            + $"catalog_only={root.Counts.CatalogOnlyCallsites} unregistered={root.Counts.UnregisteredCallsites} "
            + $"sha256={rootHash}");
        return root.Status == "VERIFIED" ? 0 : 1;
    }

    private static List<AbilityIdentity> LoadAbilities(string catalogPath)
    {
        using JsonDocument document = JsonDocument.Parse(File.ReadAllBytes(catalogPath));
        JsonElement root = document.RootElement;
        if (!root.TryGetProperty("format", out JsonElement format)
            || format.GetString() != "RENOVICE_ABILITY_CATALOG_V1")
        {
            throw new InvalidDataException("Unsupported ability catalog format");
        }

        var abilities = new List<AbilityIdentity>();
        foreach (JsonElement warframe in root.GetProperty("warframes").EnumerateArray())
        {
            string warframeName = RequiredString(warframe, "name");
            string warframeAsset = RequiredString(warframe, "warframe_asset_path");
            foreach (JsonElement ability in warframe.GetProperty("abilities").EnumerateArray())
            {
                string resolution = RequiredString(ability, "resolution_status");
                if (resolution != "RESOLVED")
                {
                    throw new InvalidDataException(
                        $"Ability catalog contains unresolved entry {warframeName}/{RequiredString(ability, "name")}");
                }
                string key = RequiredString(ability, "module_body_key").ToLowerInvariant();
                if (!BodyKeyRegex().IsMatch(key))
                {
                    throw new InvalidDataException($"Invalid body key for {warframeName}: {key}");
                }
                abilities.Add(new AbilityIdentity(
                    warframeName,
                    warframeAsset,
                    ability.GetProperty("slot").GetInt32(),
                    RequiredString(ability, "name"),
                    ExactStringAllowEmpty(ability, "ability_identifier"),
                    RequiredString(ability, "ability_asset_path"),
                    RequiredString(ability, "module_path"),
                    key,
                    RequiredString(ability, "entry_function"),
                    Path.GetFullPath(RequiredString(ability, "stock_bytecode_path"))));
            }
        }
        return abilities;
    }

    private static string RequiredString(JsonElement element, string property)
    {
        if (!element.TryGetProperty(property, out JsonElement value)
            || value.ValueKind != JsonValueKind.String
            || string.IsNullOrWhiteSpace(value.GetString()))
        {
            throw new InvalidDataException($"Missing required string property {property}");
        }
        return value.GetString()!;
    }

    private static string ExactStringAllowEmpty(JsonElement element, string property)
    {
        if (!element.TryGetProperty(property, out JsonElement value)
            || value.ValueKind != JsonValueKind.String)
        {
            throw new InvalidDataException($"Missing required string property {property}");
        }
        return value.GetString() ?? string.Empty;
    }

    private static async Task<ModuleBuildResult> BuildModuleAsync(
        string bodyKey,
        IReadOnlyList<AbilityIdentity> abilities,
        string decompiler,
        string decompilerHash,
        string semanticSdk,
        string sdkHash,
        string moduleRoot,
        bool reuse,
        CancellationToken cancellationToken)
    {
        var rejections = new List<string>();
        string modulePath = abilities.Select(item => item.ModulePath).Distinct(StringComparer.Ordinal).Single();
        string bytecode = abilities.Select(item => item.StockBytecodePath)
            .Distinct(StringComparer.OrdinalIgnoreCase).Single();
        string directory = Path.Combine(moduleRoot, bodyKey);
        Directory.CreateDirectory(directory);

        if (!File.Exists(bytecode))
        {
            rejections.Add($"MISSING_STOCK_BYTECODE:{bytecode}");
        }
        string bytecodeHash = File.Exists(bytecode) ? Sha256File(bytecode) : string.Empty;
        if (File.Exists(bytecode))
        {
            string actualBodyKey = BodyKeyHex(File.ReadAllBytes(bytecode));
            if (!string.Equals(bodyKey, actualBodyKey, StringComparison.Ordinal))
            {
                rejections.Add($"BODY_KEY_MISMATCH:expected={bodyKey}:actual={actualBodyKey}");
            }
        }

        string fidelity = Path.Combine(directory, "fidelity.luau");
        string readable = Path.Combine(directory, "readable.luau");
        string names = Path.Combine(directory, "names.tsv");
        string calls = Path.Combine(directory, "calls.tsv");
        string closures = Path.Combine(directory, "closures.tsv");
        string failureReadable = Path.Combine(directory, "failure-readable.luau");
        string stdout = Path.Combine(directory, "render.stdout.log");
        string stderr = Path.Combine(directory, "render.stderr.log");
        string cacheManifest = Path.Combine(directory, "render-inputs.json");

        bool cacheValid = reuse
            && rejections.Count == 0
            && CacheValid(
                cacheManifest,
                bodyKey,
                bytecodeHash,
                decompilerHash,
                sdkHash,
                new[] { fidelity, readable, names, calls, closures });
        if (!cacheValid && rejections.Count == 0)
        {
            DeleteIfPresent(fidelity, readable, names, calls, closures, failureReadable, stdout, stderr, cacheManifest);
            ProcessResult render = await RunProcessAsync(
                decompiler,
                new[]
                {
                    "semantic-ir-render-module-readable",
                    bytecode,
                    fidelity,
                    readable,
                    names,
                    "--semantic-sdk",
                    semanticSdk,
                    "--call-map",
                    calls,
                    "--failure-readable",
                    failureReadable,
                },
                Path.GetDirectoryName(decompiler) is { } binaryDirectory
                    ? Directory.GetParent(binaryDirectory)!.FullName
                    : Environment.CurrentDirectory,
                cancellationToken);
            File.WriteAllText(stdout, NormalizeNewlines(render.StandardOutput), new UTF8Encoding(false));
            File.WriteAllText(stderr, NormalizeNewlines(render.StandardError), new UTF8Encoding(false));
            if (render.ExitCode != 0)
            {
                rejections.Add($"SEMANTIC_RENDER_FAILED:exit={render.ExitCode}");
            }

            ProcessResult closure = await RunProcessAsync(
                decompiler,
                new[] { "closure-map", bytecode, closures },
                Directory.GetParent(Path.GetDirectoryName(decompiler)!)!.FullName,
                cancellationToken);
            File.AppendAllText(stdout, NormalizeNewlines(closure.StandardOutput), new UTF8Encoding(false));
            File.AppendAllText(stderr, NormalizeNewlines(closure.StandardError), new UTF8Encoding(false));
            if (closure.ExitCode != 0)
            {
                rejections.Add($"CLOSURE_MAP_FAILED:exit={closure.ExitCode}");
            }

            foreach (string required in new[] { fidelity, readable, names, calls, closures })
            {
                if (!File.Exists(required) || new FileInfo(required).Length == 0)
                {
                    rejections.Add($"MISSING_OR_EMPTY_ARTIFACT:{Path.GetFileName(required)}");
                }
            }
            if (rejections.Count == 0)
            {
                WriteCacheManifest(
                    cacheManifest,
                    directory,
                    bodyKey,
                    bytecodeHash,
                    decompilerHash,
                    sdkHash,
                    new[] { fidelity, readable, names, calls, closures });
            }
        }

        List<NameRow> nameRows = rejections.Count == 0 ? ReadNames(names) : new();
        List<ClosureRow> closureRows = rejections.Count == 0 ? ReadClosures(closures) : new();
        List<Callsite> callsites = rejections.Count == 0 ? ReadCallsites(calls) : new();
        string[] sourceLines = rejections.Count == 0
            ? File.ReadAllLines(readable)
            : Array.Empty<string>();
        List<ExportBinding> exports = BuildExports(nameRows, closureRows, callsites, sourceLines);
        List<AbilityEntryBinding> entries = BuildEntryBindings(abilities, exports, rejections);
        IReadOnlyDictionary<string, IReadOnlyList<string>> signalIndex = BuildSignalIndex(callsites);
        List<CleanupPair> cleanupPairs = BuildCleanupPairs(callsites);

        int registered = callsites.Count(call => call.ContractMatch != "UNREGISTERED");
        int confirmed = callsites.Count(call => call.ContractStatus == "CONFIRMED");
        int catalogOnly = callsites.Count(call => call.ContractStatus == "CATALOG_ONLY");
        int unregistered = callsites.Count(call => call.ContractMatch == "UNREGISTERED");
        int ambiguous = callsites.Count(call => call.ContractMatch.Contains("AMBIGUOUS", StringComparison.Ordinal));
        int mismatch = callsites.Count(call => call.ContractMatch.Contains("MISMATCH", StringComparison.Ordinal));
        string status = rejections.Count == 0 ? "VERIFIED" : "REJECTED";

        var generated = new SortedDictionary<string, ArtifactRecord>(StringComparer.Ordinal);
        foreach (string path in new[] { fidelity, readable, names, calls, closures, stdout, stderr, cacheManifest })
        {
            if (File.Exists(path))
            {
                generated[Path.GetFileName(path)] = Artifact(path, directory);
            }
        }

        var behavior = new ModuleBehavior(
            ModuleFormat,
            1,
            status,
            bodyKey,
            modulePath,
            File.Exists(bytecode)
                ? Artifact(bytecode, directory)
                : new ArtifactRecord(bytecode, 0, string.Empty),
            Artifact(decompiler, directory),
            Artifact(semanticSdk, directory),
            generated,
            "Callsite identities and widths come from verified DE bytecode Semantic IR. "
                + "Export-to-prototype bindings require an exact export plus a unique synchronized renderer identity. "
                + "Lexical families and cleanup pairs are search aids only. Direct calls are not transitive behavior proof.",
            new ModuleCounts(
                abilities.Count,
                exports.Count,
                exports.Count(item => item.TargetPrototype is not null),
                callsites.Count,
                registered,
                confirmed,
                catalogOnly,
                unregistered,
                ambiguous,
                mismatch,
                signalIndex.Count,
                cleanupPairs.Count),
            entries,
            exports,
            callsites,
            signalIndex,
            cleanupPairs,
            rejections.Order(StringComparer.Ordinal).ToArray());

        string behaviorPath = Path.Combine(directory, "behavior.json");
        WriteJsonAtomic(behaviorPath, behavior);
        string relativeBehavior = Path.GetRelativePath(moduleRoot, behaviorPath).Replace('\\', '/');
        var index = new ModuleIndex(
            bodyKey,
            modulePath,
            status,
            $"modules/{relativeBehavior}",
            Sha256File(behaviorPath),
            abilities.Count,
            exports.Count,
            exports.Count(item => item.TargetPrototype is not null),
            callsites.Count,
            confirmed,
            catalogOnly,
            unregistered,
            rejections.Count);
        AbilityEntryBindingIndex[] abilityIndex = entries.Select(entry => new AbilityEntryBindingIndex(
            entry.Warframe,
            entry.Slot,
            entry.Name,
            entry.AbilityIdentifier,
            abilities.Single(item => item.AbilityIdentifier == entry.AbilityIdentifier
                && item.Warframe == entry.Warframe && item.Slot == entry.Slot).AbilityAssetPath,
            modulePath,
            bodyKey,
            entry.EntryFunction,
            entry.Status,
            entry.EntryPrototype,
            index.BehaviorFile)).ToArray();
        return new ModuleBuildResult(behavior, index, abilityIndex);
    }

    private static IReadOnlyDictionary<string, IReadOnlyList<string>> BuildSignalIndex(
        IReadOnlyList<Callsite> callsites)
    {
        var result = new SortedDictionary<string, IReadOnlyList<string>>(StringComparer.Ordinal);
        foreach (IGrouping<string, Callsite> group in callsites
            .SelectMany(call => call.LexicalFamilies.Select(family => (Family: family, Call: call)))
            .GroupBy(item => item.Family, item => item.Call, StringComparer.Ordinal)
            .OrderBy(group => group.Key, StringComparer.Ordinal))
        {
            result[group.Key] = group.Select(call => call.Id).Distinct(StringComparer.Ordinal).ToArray();
        }
        return result;
    }

    private static List<ExportBinding> BuildExports(
        IReadOnlyList<NameRow> names,
        IReadOnlyList<ClosureRow> closures,
        IReadOnlyList<Callsite> callsites,
        IReadOnlyList<string> sourceLines)
    {
        var exports = new List<ExportBinding>();
        foreach (NameRow row in names
            .Where(row => row.Confidence == "EXACT_EXPORT"
                && row.Evidence.StartsWith("global store ", StringComparison.Ordinal))
            .OrderBy(row => row.Evidence, StringComparer.Ordinal))
        {
            string exportedName = row.Evidence["global store ".Length..];
            (int? target, int? line, string resolution) = ResolveExportPrototype(
                row.Readable,
                row.Prototype,
                row.Web,
                sourceLines,
                closures);
            string[] directCalls = target is null
                ? Array.Empty<string>()
                : callsites.Where(call => call.Prototype == target.Value)
                    .Select(call => call.Id).ToArray();
            exports.Add(new ExportBinding(
                exportedName,
                row.Readable,
                row.Prototype,
                row.Web,
                row.Canonical,
                row.Confidence,
                row.Evidence,
                ExportRoleHint(exportedName),
                target,
                line,
                resolution,
                directCalls));
        }
        return exports;
    }

    private static List<AbilityEntryBinding> BuildEntryBindings(
        IReadOnlyList<AbilityIdentity> abilities,
        IReadOnlyList<ExportBinding> exports,
        List<string> rejections)
    {
        var result = new List<AbilityEntryBinding>();
        foreach (AbilityIdentity ability in abilities)
        {
            ExportBinding[] matches = exports
                .Where(export => export.ExportedName == ability.EntryFunction)
                .ToArray();
            bool verified = matches.Length == 1 && matches[0].TargetPrototype is not null;
            if (!verified)
            {
                rejections.Add(
                    $"ENTRY_BINDING_REJECTED:{ability.Warframe}:{ability.Slot}:{ability.EntryFunction}:matches={matches.Length}");
            }
            result.Add(new AbilityEntryBinding(
                ability.Warframe,
                ability.WarframeAssetPath,
                ability.Slot,
                ability.Name,
                ability.AbilityIdentifier,
                ability.AbilityAssetPath,
                ability.EntryFunction,
                verified ? "VERIFIED" : "REJECTED",
                verified ? matches[0].TargetPrototype : null,
                verified ? matches[0].DirectCallsiteIds : Array.Empty<string>()));
        }
        return result;
    }

    private static (int? Target, int? DefinitionLine, string Resolution) ResolveExportPrototype(
        string alias,
        int rootPrototype,
        int rootWeb,
        IReadOnlyList<string> sourceLines,
        IReadOnlyList<ClosureRow> closures)
    {
        if (string.IsNullOrWhiteSpace(alias))
        {
            return (null, null, "MISSING_READABLE_ALIAS");
        }
        Regex namedDefinition = new(
            "^" + Regex.Escape(alias) + @"\s*=\s*function\((?<parameters>[^)]*)\)\s*$",
            RegexOptions.CultureInvariant);
        Regex frameValueDefinition = new(
            "^frame_" + rootPrototype.ToString(CultureInfo.InvariantCulture)
                + @"\[" + rootWeb.ToString(CultureInfo.InvariantCulture)
                + @"\]\s*=\s*function\((?<parameters>[^)]*)\)\s*$",
            RegexOptions.CultureInvariant);
        var matches = new List<(int Index, Match Match)>();
        for (int index = 0; index < sourceLines.Count; ++index)
        {
            Match match = namedDefinition.Match(sourceLines[index]);
            if (match.Success)
            {
                matches.Add((index, match));
            }
        }
        string sourceBasis = string.Empty;
        if (matches.Count == 0)
        {
            for (int index = 0; index < sourceLines.Count; ++index)
            {
                Match match = frameValueDefinition.Match(sourceLines[index]);
                if (match.Success)
                {
                    matches.Add((index, match));
                }
            }
            sourceBasis = "ROOT_VALUE_WEB_";
        }
        if (matches.Count != 1)
        {
            return (null, null, $"FUNCTION_DEFINITION_COUNT_{matches.Count}");
        }

        int start = matches[0].Index;
        int end = start + 1;
        while (end < sourceLines.Count && sourceLines[end] != "end")
        {
            ++end;
        }
        if (end >= sourceLines.Count)
        {
            return (null, start + 1, "FUNCTION_END_NOT_FOUND");
        }

        var candidates = new List<int>();
        foreach (Match parameter in ParameterPrototypeRegex().Matches(matches[0].Match.Groups["parameters"].Value))
        {
            candidates.Add(int.Parse(parameter.Groups["prototype"].Value, CultureInfo.InvariantCulture));
        }
        int? resolved = Unique(candidates);
        string basis = sourceBasis + "PARAMETER_IDENTITY";

        if (resolved is null)
        {
            candidates.Clear();
            for (int line = start + 1; line <= Math.Min(end, start + 12); ++line)
            {
                foreach (Match local in LocalPrototypeRegex().Matches(sourceLines[line]))
                {
                    string value = local.Groups["prototype"].Success
                        ? local.Groups["prototype"].Value
                        : local.Groups["prototype2"].Value;
                    candidates.Add(int.Parse(value, CultureInfo.InvariantCulture));
                }
            }
            resolved = Unique(candidates);
            basis = sourceBasis + "LOCAL_RENDERER_IDENTITY";
        }

        if (resolved is null)
        {
            candidates.Clear();
            for (int line = start + 1; line < end; ++line)
            {
                foreach (Match token in AnyPrototypeRegex().Matches(sourceLines[line]))
                {
                    string value = token.Groups["prototype"].Success
                        ? token.Groups["prototype"].Value
                        : token.Groups["prototype2"].Value;
                    int parsed = int.Parse(value, CultureInfo.InvariantCulture);
                    if (parsed != rootPrototype)
                    {
                        candidates.Add(parsed);
                    }
                }
            }
            int[] closureTargets = closures
                .Where(closure => closure.ParentPrototype == rootPrototype && closure.Status == "PASS")
                .Select(closure => closure.TargetPrototype)
                .Distinct()
                .ToArray();
            resolved = Unique(candidates.Where(closureTargets.Contains));
            basis = sourceBasis + "BLOCK_RENDERER_IDENTITY_INTERSECT_CLOSURE_MAP";
        }

        if (resolved is null)
        {
            return (null, start + 1, "NO_UNIQUE_RENDERER_PROTOTYPE");
        }
        bool closureConfirmed = closures.Any(
            closure => closure.ParentPrototype == rootPrototype
                && closure.TargetPrototype == resolved.Value
                && closure.Status == "PASS");
        if (!closureConfirmed)
        {
            return (null, start + 1, $"{basis}_ABSENT_FROM_CLOSURE_MAP");
        }
        return (resolved, start + 1, $"{basis}_AND_CLOSURE_MAP");
    }

    private static int? Unique(IEnumerable<int> values)
    {
        int[] distinct = values.Distinct().ToArray();
        return distinct.Length == 1 ? distinct[0] : null;
    }

    private static List<CleanupPair> BuildCleanupPairs(IReadOnlyList<Callsite> callsites)
    {
        string[] patterns = { "Add|Remove", "Push|Pop", "Enable|Disable", "Start|Stop", "Create|Destroy", "Give|Remove" };
        var byName = callsites
            .GroupBy(call => call.Name, StringComparer.Ordinal)
            .ToDictionary(group => group.Key, group => group.Select(call => call.Id).ToArray(), StringComparer.Ordinal);
        var result = new List<CleanupPair>();
        var seen = new HashSet<string>(StringComparer.Ordinal);
        foreach (string pattern in patterns)
        {
            string[] pair = pattern.Split('|');
            foreach (string forward in byName.Keys.Where(name => name.StartsWith(pair[0], StringComparison.Ordinal)))
            {
                string suffix = forward[pair[0].Length..];
                if (suffix.Length == 0)
                {
                    continue;
                }
                string reverse = pair[1] + suffix;
                string identity = forward + "\0" + reverse;
                if (!byName.ContainsKey(reverse) || !seen.Add(identity))
                {
                    continue;
                }
                result.Add(new CleanupPair(
                    forward,
                    reverse,
                    pattern,
                    "LEXICAL_NAME_PAIR_ONLY",
                    byName[forward],
                    byName[reverse]));
            }
        }
        return result.OrderBy(item => item.Forward, StringComparer.Ordinal)
            .ThenBy(item => item.Reverse, StringComparer.Ordinal)
            .ToList();
    }

    private static List<NameRow> ReadNames(string path)
    {
        TsvTable table = TsvTable.Read(path);
        return table.Rows.Select(row => new NameRow(
            table.Int(row, "prototype"),
            table.Int(row, "web"),
            table.String(row, "canonical"),
            table.String(row, "readable"),
            table.String(row, "confidence"),
            table.String(row, "evidence"))).ToList();
    }

    private static List<ClosureRow> ReadClosures(string path)
    {
        TsvTable table = TsvTable.Read(path);
        return table.Rows.Select(row => new ClosureRow(
            table.Int(row, "parent_proto"),
            table.Int(row, "instruction"),
            table.String(row, "op"),
            table.Int(row, "destination_register"),
            table.String(row, "operand_namespace"),
            table.Int(row, "operand_index"),
            table.Int(row, "target_proto"),
            table.Int(row, "target_params"),
            table.Int(row, "target_upvalues"),
            table.Int(row, "target_maxstack"),
            table.Int(row, "capture_count"),
            table.String(row, "captures"),
            table.String(row, "status"))).ToList();
    }

    private static List<Callsite> ReadCallsites(string path)
    {
        TsvTable table = TsvTable.Read(path);
        var callsites = new List<Callsite>(table.Rows.Count);
        foreach (string[] row in table.Rows)
        {
            int prototype = table.Int(row, "prototype");
            int block = table.Int(row, "block");
            int instruction = table.Int(row, "instruction");
            int occurrence = table.Int(row, "source_occurrence");
            string kind = table.String(row, "kind");
            string name = table.String(row, "name");
            string id = $"p{prototype}:i{instruction}:o{occurrence}:{kind}:{name}";
            callsites.Add(new Callsite(
                id,
                prototype,
                block,
                instruction,
                occurrence,
                table.Int(row, "effect_order"),
                kind,
                name,
                NullIfEmpty(table.String(row, "name_hash")),
                table.NullableInt(row, "receiver_web"),
                NullIfEmpty(table.String(row, "receiver_type")),
                NullIfEmpty(table.String(row, "receiver_type_confidence")),
                NullIfEmpty(table.String(row, "receiver_type_evidence")),
                IntegerList(table.String(row, "argument_webs")),
                table.Int(row, "explicit_argument_count"),
                table.Bool(row, "open_arguments"),
                IntegerList(table.String(row, "result_webs")),
                table.Int(row, "result_count"),
                table.Bool(row, "open_results"),
                NullIfEmpty(table.String(row, "descriptor")),
                NullIfEmpty(table.String(row, "contract_confidence")),
                NullIfEmpty(table.String(row, "contract_status")),
                NullIfEmpty(table.String(row, "evidence")),
                NullIfEmpty(table.String(row, "parameters")),
                NullIfEmpty(table.String(row, "returns")),
                table.String(row, "contract_match"),
                table.Int(row, "readable_line"),
                table.Int(row, "readable_column"),
                LexicalFamilies(name)));
        }
        return callsites
            .OrderBy(call => call.Prototype)
            .ThenBy(call => call.Instruction)
            .ThenBy(call => call.SourceOccurrence)
            .ThenBy(call => call.EffectOrder)
            .ToList();
    }

    private static IReadOnlyList<int> IntegerList(string value)
    {
        if (value.Length == 0)
        {
            return Array.Empty<int>();
        }
        return value.Split(';', StringSplitOptions.RemoveEmptyEntries)
            .Select(item => int.Parse(item, CultureInfo.InvariantCulture))
            .ToArray();
    }

    private static string? NullIfEmpty(string value) => value.Length == 0 ? null : value;

    private static IReadOnlyList<string> LexicalFamilies(string name)
    {
        var families = new SortedSet<string>(StringComparer.Ordinal);
        if (name.Contains("Damage", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Health", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Shield", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Overguard", StringComparison.OrdinalIgnoreCase))
        {
            families.Add("DAMAGE_OR_SURVIVABILITY_NAME");
        }
        if (name.Contains("Upgrade", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Modifier", StringComparison.OrdinalIgnoreCase)
            || name is "ModifyValue" or "GetAbilityStats" or "SetAbilityStats")
        {
            families.Add("MODIFIER_OR_SCALING_NAME");
        }
        if (name.Contains("Callback", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Contact", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Collision", StringComparison.OrdinalIgnoreCase))
        {
            families.Add("CALLBACK_OR_CONTACT_NAME");
        }
        if (name is "IsNull" or "IsKilled" or "IsDead" or "GetHealth"
            || name.StartsWith("Destroy", StringComparison.Ordinal))
        {
            families.Add("LIVENESS_OR_LIFETIME_NAME");
        }
        if (name.Contains("Authoritative", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Server", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Client", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Owner", StringComparison.OrdinalIgnoreCase)
            || name.Contains("LocalPlayer", StringComparison.OrdinalIgnoreCase))
        {
            families.Add("AUTHORITY_OR_OWNERSHIP_NAME");
        }
        if (name is "Sleep" or "Wait" or "DeltaTime" or "RealDeltaTime"
            || name.Contains("Timer", StringComparison.OrdinalIgnoreCase)
            || name.StartsWith("Start", StringComparison.Ordinal)
            || name.StartsWith("Stop", StringComparison.Ordinal))
        {
            families.Add("TIMING_OR_YIELD_NAME");
        }
        if (name.Contains("Spawn", StringComparison.OrdinalIgnoreCase)
            || name.StartsWith("Create", StringComparison.Ordinal)
            || name.StartsWith("Destroy", StringComparison.Ordinal))
        {
            families.Add("SPAWN_OR_DESTRUCTION_NAME");
        }
        if (name.Contains("Hud", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Flash", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Localize", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Notify", StringComparison.OrdinalIgnoreCase)
            || name.Contains("AbilityUpgradeLevelInfo", StringComparison.OrdinalIgnoreCase))
        {
            families.Add("PRESENTATION_OR_CARD_NAME");
        }
        string[] mutationPrefixes =
        {
            "Set", "Add", "Remove", "Enable", "Disable", "Apply", "Destroy",
            "Push", "Pop", "Give", "Cancel", "Stop", "Start", "Create", "Clear",
        };
        if (mutationPrefixes.Any(prefix => name.StartsWith(prefix, StringComparison.Ordinal)))
        {
            families.Add("POSSIBLE_MUTATION_NAME");
        }
        return families.ToArray();
    }

    private static string ExportRoleHint(string name)
    {
        if (name is "ActivateAbility" or "DeactivateAbility" or "InitializeAbility"
            or "EvaluateAbility" or "NpcEvaluateAbility" or "GetAbilityUpgradeLevelInfo")
        {
            return name.ToUpperInvariant();
        }
        if (name.Contains("Activate", StringComparison.OrdinalIgnoreCase))
        {
            return "ACTIVATION_NAME_HINT";
        }
        if (name.Contains("Deactivate", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Cleanup", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Destroy", StringComparison.OrdinalIgnoreCase))
        {
            return "DEACTIVATION_OR_CLEANUP_NAME_HINT";
        }
        if (name.Contains("Evaluate", StringComparison.OrdinalIgnoreCase))
        {
            return "EVALUATION_NAME_HINT";
        }
        if (name.Contains("Initialize", StringComparison.OrdinalIgnoreCase))
        {
            return "INITIALIZATION_NAME_HINT";
        }
        if (name.Contains("Contact", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Callback", StringComparison.OrdinalIgnoreCase))
        {
            return "CALLBACK_NAME_HINT";
        }
        return "UNCLASSIFIED_NAME_HINT";
    }

    private static async Task<ProcessResult> RunProcessAsync(
        string executable,
        IReadOnlyList<string> arguments,
        string workingDirectory,
        CancellationToken cancellationToken)
    {
        var start = new ProcessStartInfo(executable)
        {
            WorkingDirectory = workingDirectory,
            UseShellExecute = false,
            CreateNoWindow = true,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
        };
        foreach (string argument in arguments)
        {
            start.ArgumentList.Add(argument);
        }
        using Process process = Process.Start(start)
            ?? throw new InvalidOperationException($"Unable to start {executable}");
        Task<string> stdout = process.StandardOutput.ReadToEndAsync(cancellationToken);
        Task<string> stderr = process.StandardError.ReadToEndAsync(cancellationToken);
        await process.WaitForExitAsync(cancellationToken);
        return new ProcessResult(process.ExitCode, await stdout, await stderr);
    }

    private static bool CacheValid(
        string manifestPath,
        string bodyKey,
        string bytecodeHash,
        string decompilerHash,
        string sdkHash,
        IReadOnlyList<string> artifacts)
    {
        try
        {
            if (!File.Exists(manifestPath))
            {
                return false;
            }
            using JsonDocument document = JsonDocument.Parse(File.ReadAllBytes(manifestPath));
            JsonElement root = document.RootElement;
            if (RequiredString(root, "body_key") != bodyKey
                || RequiredString(root, "bytecode_sha256") != bytecodeHash
                || RequiredString(root, "decompiler_sha256") != decompilerHash
                || RequiredString(root, "semantic_sdk_sha256") != sdkHash)
            {
                return false;
            }
            JsonElement artifactObject = root.GetProperty("artifacts");
            foreach (string path in artifacts)
            {
                string file = Path.GetFileName(path);
                if (!File.Exists(path)
                    || !artifactObject.TryGetProperty(file, out JsonElement record)
                    || record.GetProperty("sha256").GetString() != Sha256File(path)
                    || record.GetProperty("bytes").GetInt64() != new FileInfo(path).Length)
                {
                    return false;
                }
            }
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static void WriteCacheManifest(
        string manifestPath,
        string directory,
        string bodyKey,
        string bytecodeHash,
        string decompilerHash,
        string sdkHash,
        IReadOnlyList<string> artifacts)
    {
        var records = new SortedDictionary<string, ArtifactRecord>(StringComparer.Ordinal);
        foreach (string path in artifacts)
        {
            records[Path.GetFileName(path)] = Artifact(path, directory);
        }
        WriteJsonAtomic(
            manifestPath,
            new InputRecord(bodyKey, bytecodeHash, decompilerHash, sdkHash, records));
    }

    private static ArtifactRecord Artifact(string path, string relativeTo)
    {
        string file = Path.GetRelativePath(relativeTo, path).Replace('\\', '/');
        return new ArtifactRecord(file, new FileInfo(path).Length, Sha256File(path));
    }

    private static void WriteJsonAtomic<T>(string path, T value)
    {
        string temporary = path + ".tmp";
        byte[] bytes = JsonSerializer.SerializeToUtf8Bytes(value, JsonOptions);
        File.WriteAllBytes(temporary, bytes.Concat(new byte[] { (byte)'\n' }).ToArray());
        File.Move(temporary, path, true);
    }

    private static void WriteAbilityIndex(
        string path,
        IReadOnlyList<AbilityEntryBindingIndex> abilities)
    {
        var output = new StringBuilder();
        output.AppendLine(
            "warframe\tslot\tability\tability_identifier\tability_asset_path\tmodule_path\tbody_key\tentry_function\tstatus\tentry_prototype\tbehavior_file");
        foreach (AbilityEntryBindingIndex ability in abilities)
        {
            output.Append(Tsv(ability.Warframe)).Append('\t')
                .Append(ability.Slot.ToString(CultureInfo.InvariantCulture)).Append('\t')
                .Append(Tsv(ability.Name)).Append('\t')
                .Append(Tsv(ability.AbilityIdentifier)).Append('\t')
                .Append(Tsv(ability.AbilityAssetPath)).Append('\t')
                .Append(Tsv(ability.ModulePath)).Append('\t')
                .Append(ability.BodyKey).Append('\t')
                .Append(Tsv(ability.EntryFunction)).Append('\t')
                .Append(ability.Status).Append('\t')
                .Append(ability.EntryPrototype?.ToString(CultureInfo.InvariantCulture) ?? string.Empty).Append('\t')
                .Append(Tsv(ability.BehaviorFile)).Append('\n');
        }
        WriteTextAtomic(path, output.ToString());
    }

    private static void WriteApiUsage(
        string path,
        IReadOnlyList<ModuleBuildResult> modules)
    {
        var usage = modules
            .SelectMany(module => module.Behavior.Callsites.Select(call => (Module: module, Call: call)))
            .GroupBy(item => item.Call.Kind + "\0" + item.Call.Name + "\0" + (item.Call.NameHash ?? string.Empty), StringComparer.Ordinal)
            .Select(group =>
            {
                Callsite first = group.First().Call;
                string[] moduleKeys = group.Select(item => item.Module.Behavior.BodyKey)
                    .Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal).ToArray();
                string[] abilityIds = group.SelectMany(item => item.Module.Behavior.Abilities)
                    .Select(ability => ability.AbilityIdentifier)
                    .Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal).ToArray();
                return new
                {
                    first.Kind,
                    first.Name,
                    first.NameHash,
                    Calls = group.Count(),
                    Modules = moduleKeys.Length,
                    Abilities = abilityIds.Length,
                    ArgumentShapes = group.Select(item => Shape(
                            item.Call.ExplicitArgumentCount, item.Call.OpenArguments))
                        .Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal).ToArray(),
                    ResultShapes = group.Select(item => Shape(item.Call.ResultCount, item.Call.OpenResults))
                        .Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal).ToArray(),
                    ContractStatuses = group.Select(item => item.Call.ContractStatus ?? "UNREGISTERED")
                        .Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal).ToArray(),
                    ContractConfidences = group.Select(item => item.Call.ContractConfidence ?? string.Empty)
                        .Where(value => value.Length != 0)
                        .Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal).ToArray(),
                    ReceiverTypes = group.Select(item => item.Call.ReceiverType ?? string.Empty)
                        .Where(value => value.Length != 0)
                        .Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal).ToArray(),
                    LexicalFamilies = group.SelectMany(item => item.Call.LexicalFamilies)
                        .Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal).ToArray(),
                    ModuleKeys = moduleKeys,
                };
            })
            .OrderByDescending(item => item.Modules)
            .ThenByDescending(item => item.Calls)
            .ThenBy(item => item.Kind, StringComparer.Ordinal)
            .ThenBy(item => item.Name, StringComparer.Ordinal)
            .ToArray();

        var output = new StringBuilder();
        output.AppendLine(
            "kind\tname\tname_hash\tcalls\tmodules\tabilities\targument_shapes\tresult_shapes\tcontract_statuses\tcontract_confidences\treceiver_types\tlexical_families\tmodule_keys");
        foreach (var item in usage)
        {
            output.Append(Tsv(item.Kind)).Append('\t')
                .Append(Tsv(item.Name)).Append('\t')
                .Append(Tsv(item.NameHash ?? string.Empty)).Append('\t')
                .Append(item.Calls.ToString(CultureInfo.InvariantCulture)).Append('\t')
                .Append(item.Modules.ToString(CultureInfo.InvariantCulture)).Append('\t')
                .Append(item.Abilities.ToString(CultureInfo.InvariantCulture)).Append('\t')
                .Append(string.Join(';', item.ArgumentShapes)).Append('\t')
                .Append(string.Join(';', item.ResultShapes)).Append('\t')
                .Append(string.Join(';', item.ContractStatuses)).Append('\t')
                .Append(string.Join(';', item.ContractConfidences)).Append('\t')
                .Append(string.Join(';', item.ReceiverTypes)).Append('\t')
                .Append(string.Join(';', item.LexicalFamilies)).Append('\t')
                .Append(string.Join(';', item.ModuleKeys)).Append('\n');
        }
        WriteTextAtomic(path, output.ToString());
    }

    private static string Shape(int count, bool open) => open ? $"{count}+" : count.ToString(CultureInfo.InvariantCulture);

    private static string Tsv(string value) => value.Replace('\t', ' ').Replace('\r', ' ').Replace('\n', ' ');

    private static void WriteTextAtomic(string path, string text)
    {
        string temporary = path + ".tmp";
        File.WriteAllText(temporary, NormalizeNewlines(text), new UTF8Encoding(false));
        File.Move(temporary, path, true);
    }

    private static string NormalizeNewlines(string value) => value.Replace("\r\n", "\n").Replace('\r', '\n');

    private static string Sha256File(string path)
    {
        using FileStream stream = File.OpenRead(path);
        return Convert.ToHexString(SHA256.HashData(stream));
    }

    private static string BodyKeyHex(ReadOnlySpan<byte> bytes)
    {
        ulong hash = BodyKeyBasis;
        foreach (byte value in bytes)
        {
            hash ^= value;
            hash *= BodyKeyPrime;
        }
        return hash.ToString("x16", CultureInfo.InvariantCulture);
    }

    private static void DeleteIfPresent(params string[] paths)
    {
        foreach (string path in paths)
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
        }
    }

    private static int RunSelfTest()
    {
        int failures = 0;
        void Check(bool condition, string name)
        {
            Console.WriteLine($"{(condition ? "PASS" : "FAIL")}\t{name}");
            if (!condition)
            {
                ++failures;
            }
        }

        Check(BodyKeyHex(Encoding.ASCII.GetBytes("abc")) == "e16801510db89efd",
            "deployed nonstandard FNV body key");
        Check(LexicalFamilies("ReplicaLocallyAuthoritative").Contains("AUTHORITY_OR_OWNERSHIP_NAME"),
            "authority family remains explicitly lexical");
        Check(LexicalFamilies("SetDamageCallback").SequenceEqual(new[]
            {
                "CALLBACK_OR_CONTACT_NAME",
                "DAMAGE_OR_SURVIVABILITY_NAME",
                "POSSIBLE_MUTATION_NAME",
            }), "multi-family signal classification is deterministic");

        string[] source =
        {
            "activateAbilityFunction = function(p11_0, p11_1)",
            "    local frame_11 = {}",
            "    p11_0:SetCanRun(true)",
            "end",
        };
        ClosureRow[] closures =
        {
            new(21, 80, "NEWCLOSURE", 18, "child", 11, 11, 2, 1, 8, 1, "0=VAL:R1", "PASS"),
        };
        (int? target, int? line, string resolution) = ResolveExportPrototype(
            "activateAbilityFunction", 21, 80, source, closures);
        Check(target == 11 && line == 1 && resolution == "PARAMETER_IDENTITY_AND_CLOSURE_MAP",
            "exact export resolves through renderer identity and closure map");

        string[] frameValueSource =
        {
            "frame_21[80] = function(p11_0, p11_1)",
            "    local frame_11 = {}",
            "    p11_0:SetCanRun(true)",
            "end",
            "ActivateAbility = frame_21[80]",
        };
        (target, line, resolution) = ResolveExportPrototype(
            "activateAbilityFunction", 21, 80, frameValueSource, closures);
        Check(target == 11 && line == 1
                && resolution == "ROOT_VALUE_WEB_PARAMETER_IDENTITY_AND_CLOSURE_MAP",
            "frame-value export resolves through exact web and closure map");

        Callsite[] pairCalls =
        {
            SyntheticCall("AddGravityMultiplier", "p1:i2:o0:method:AddGravityMultiplier"),
            SyntheticCall("RemoveGravityMultiplier", "p2:i4:o0:method:RemoveGravityMultiplier"),
        };
        List<CleanupPair> pairs = BuildCleanupPairs(pairCalls);
        Check(pairs.Count == 1 && pairs[0].EvidenceBoundary == "LEXICAL_NAME_PAIR_ONLY",
            "cleanup candidates never become semantic contracts");

        Console.WriteLine($"ABILITY BEHAVIOR SELFTEST failures={failures}");
        return failures == 0 ? 0 : 1;
    }

    private static Callsite SyntheticCall(string name, string id) => new(
        id, 0, 0, 0, 0, 0, "method", name, null, null, null, null, null,
        Array.Empty<int>(), 0, false, Array.Empty<int>(), 0, false,
        null, null, null, null, null, null, "UNREGISTERED", 1, 1, LexicalFamilies(name));

    private sealed class TsvTable
    {
        private readonly Dictionary<string, int> columns;

        private TsvTable(Dictionary<string, int> columns, List<string[]> rows)
        {
            this.columns = columns;
            Rows = rows;
        }

        public List<string[]> Rows { get; }

        public static TsvTable Read(string path)
        {
            string[] lines = File.ReadAllLines(path);
            if (lines.Length == 0)
            {
                throw new InvalidDataException($"Empty TSV: {path}");
            }
            string[] header = lines[0].Split('\t');
            var columns = new Dictionary<string, int>(StringComparer.Ordinal);
            for (int index = 0; index < header.Length; ++index)
            {
                if (!columns.TryAdd(header[index], index))
                {
                    throw new InvalidDataException($"Duplicate TSV column {header[index]} in {path}");
                }
            }
            var rows = new List<string[]>();
            for (int line = 1; line < lines.Length; ++line)
            {
                if (lines[line].Length == 0)
                {
                    continue;
                }
                string[] values = lines[line].Split('\t');
                if (values.Length != header.Length)
                {
                    throw new InvalidDataException(
                        $"TSV width mismatch {path}:{line + 1} expected={header.Length} actual={values.Length}");
                }
                rows.Add(values);
            }
            return new TsvTable(columns, rows);
        }

        public string String(string[] row, string column)
        {
            if (!columns.TryGetValue(column, out int index))
            {
                throw new InvalidDataException($"Missing TSV column {column}");
            }
            return row[index];
        }

        public int Int(string[] row, string column)
        {
            string value = String(row, column);
            if (!int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out int result))
            {
                throw new InvalidDataException($"Invalid integer in TSV column {column}: {value}");
            }
            return result;
        }

        public int? NullableInt(string[] row, string column)
        {
            string value = String(row, column);
            if (value.Length == 0 || value == "-1")
            {
                return null;
            }
            if (!int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out int result))
            {
                throw new InvalidDataException($"Invalid nullable integer in TSV column {column}: {value}");
            }
            return result;
        }

        public bool Bool(string[] row, string column)
        {
            string value = String(row, column);
            if (value == "true")
            {
                return true;
            }
            if (value == "false")
            {
                return false;
            }
            throw new InvalidDataException($"Invalid Boolean in TSV column {column}: {value}");
        }
    }

    [GeneratedRegex("^[0-9a-f]{16}$", RegexOptions.CultureInvariant)]
    private static partial Regex BodyKeyRegex();

    [GeneratedRegex(@"\bp(?<prototype>\d+)_\d+\b", RegexOptions.CultureInvariant)]
    private static partial Regex ParameterPrototypeRegex();

    [GeneratedRegex(@"\b(?:frame|cfg)_(?<prototype>\d+)\b|\blocal\s+v(?<prototype2>\d+)_\d+\b", RegexOptions.CultureInvariant)]
    private static partial Regex LocalPrototypeRegex();

    [GeneratedRegex(@"\b(?:p|v)(?<prototype>\d+)_\d+\b|\b(?:frame|cfg)_(?<prototype2>\d+)\b", RegexOptions.CultureInvariant)]
    private static partial Regex AnyPrototypeRegex();
}
