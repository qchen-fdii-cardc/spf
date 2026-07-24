function outFile = build_mltbx(outDir)
    %BUILD_MLTBX Package matlab_dist into an .mltbx file.
    %   outFile = build_mltbx() writes to matlab_dist/dist.
    %   outFile = build_mltbx(outDir) writes to outDir.
    %
    %   Strict mode: this function fails immediately on any packaging error.

    toolboxRoot = fileparts(mfilename('fullpath'));

    if nargin < 1 || strlength(string(outDir)) == 0
        outDir = fullfile(toolboxRoot, 'dist');
    end

    outDir = localToAbsolutePath(char(string(outDir)), toolboxRoot);

    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    version = localReadVersion(fullfile(fileparts(toolboxRoot), 'Cargo.toml'));
    outFile = fullfile(outDir, sprintf('spf_matlab_%s.mltbx', version));

    if exist('matlab.addons.toolbox.ToolboxOptions', 'class') ~= 8
        error('spf:toolboxOptionsMissing', 'MATLAB ToolboxOptions API is unavailable in this environment.');
    end

    toolboxId = 'qchen-fdii-cardc-spf';
    opts = matlab.addons.toolbox.ToolboxOptions(toolboxRoot, toolboxId);

    opts = localSetIfProp(opts, 'ToolboxName', 'SPF MATLAB Interface');
    opts = localSetIfProp(opts, 'ToolboxVersion', version);
    opts = localSetIfProp(opts, 'Summary', 'MATLAB bindings for the spf Rust library');
    opts = localSetIfProp(opts, 'Description', 'MATLAB bindings for spf via shared library and loadlibrary.');
    opts = localSetIfProp(opts, 'AuthorName', 'spf contributors');

    localPackageToolbox(opts, outFile);
    fprintf('Created toolbox: %s\n', outFile);

end

function opts = localSetIfProp(opts, propName, value)

    mc = metaclass(opts);
    propList = mc.PropertyList;
    propNames = string({propList.Name});
    idx = find(propNames == string(propName), 1);

    if isempty(idx)
        return;
    end

    if string(propList(idx).SetAccess) == "public"
        opts.(propName) = value;
    end

end

function localPackageToolbox(opts, outFile)
    tempRoot = fullfile(fileparts(outFile), 'tmp');

    if ~exist(tempRoot, 'dir')
        mkdir(tempRoot);
    end

    setenv('TMP', tempRoot);
    setenv('TEMP', tempRoot);

    opts = localSetIfProp(opts, 'OutputFile', outFile);
    matlab.addons.toolbox.packageToolbox(opts);

    if ~isfile(outFile)
        error('spf:packageToolboxNoArtifact', 'packageToolbox did not create expected artifact: %s', outFile);
    end

end

function version = localReadVersion(cargoTomlPath)
    text = fileread(cargoTomlPath);
    token = regexp(text, '(?m)^version\s*=\s*"([^"]+)"\s*$', 'tokens', 'once');

    if isempty(token)
        version = '0.1.0';
    else
        version = token{1};
    end

end

function absPath = localToAbsolutePath(pathIn, baseDir)
    p = strtrim(char(pathIn));

    isWindowsAbs = ~isempty(regexp(p, '^[A-Za-z]:[\\/]', 'once')) || startsWith(p, '\\');
    isUnixAbs = startsWith(p, '/');

    if isWindowsAbs || isUnixAbs
        absPath = p;
        return;
    end

    absPath = fullfile(baseDir, p);
end
