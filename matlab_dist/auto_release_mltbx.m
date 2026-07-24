function artifactFile = auto_release_mltbx(outDir, runCargoBuild)
    %AUTO_RELEASE_MLTBX Build and package SPF MATLAB toolbox for release.
    %   artifactFile = auto_release_mltbx()
    %   artifactFile = auto_release_mltbx(outDir)
    %   artifactFile = auto_release_mltbx(outDir, runCargoBuild)
    %
    %   This script is designed for CI and local release automation.
    %   It performs these steps:
    %   1) Optionally run cargo build --release
    %   2) Stage binary and header via prepare_binaries
    %   3) Package toolbox via build_mltbx
    %   4) Verify artifact exists and write release metadata

    toolboxRoot = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(toolboxRoot);

    if nargin < 1 || strlength(string(outDir)) == 0
        outDir = fullfile(toolboxRoot, 'dist');
    end

    if nargin < 2
        runCargoBuild = true;
    end

    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    apiAvailable = localHasPackageToolboxApi();

    if ~apiAvailable
        fprintf(['Warning: packageToolbox API probe did not resolve in this environment.\n' ...
                 'Proceeding to attempt packaging anyway.\n']);
    end

    if runCargoBuild
        oldDir = pwd;
        cleanupObj = onCleanup(@() cd(oldDir));
        cd(repoRoot);

        fprintf('Running cargo build --release...\n');
        [status, cmdout] = system('cargo build --release');
        fprintf('%s\n', cmdout);

        if status ~= 0
            error('spf:cargoBuildFailed', 'cargo build --release failed with exit code %d.', status);
        end

        clear cleanupObj;
        cd(oldDir);
    end

    prepare_binaries();

    artifactFile = build_mltbx(outDir);
    artifactFile = char(string(artifactFile));

    if ~isfile(artifactFile)

        if ~apiAvailable
            error('spf:headlessPackagingUnavailable', ['Toolbox artifact was not generated at: %s\n' ...
                          'This MATLAB environment likely does not support headless toolbox packaging.\n' ...
                      'Use MATLAB UI: APPS > Package Toolbox, source folder matlab_dist.'], artifactFile);
        end

        error('spf:artifactMissing', ['Toolbox packaging did not produce an artifact at: %s\n' ...
                  'Check build_mltbx output/logs for packaging errors.'], artifactFile);
    end

    manifestFile = fullfile(outDir, 'release_manifest.txt');
    localWriteManifest(manifestFile, artifactFile, repoRoot);

    fprintf('Release artifact: %s\n', artifactFile);
    fprintf('Manifest file: %s\n', manifestFile);
end

function tf = localHasPackageToolboxApi()
    tf = false;

    if exist('matlab.addons.toolbox.ToolboxOptions', 'class') ~= 8
        return;
    end

    if exist('matlab.addons.toolbox.packageToolbox', 'file') ~= 0
        tf = true;
        return;
    end

    if exist('matlab.addons.toolbox.packageToolbox', 'builtin') ~= 0
        tf = true;
        return;
    end

    tf = ~isempty(which('matlab.addons.toolbox.packageToolbox'));
end

function localWriteManifest(manifestFile, artifactFile, repoRoot)
    info = dir(artifactFile);
    version = localReadVersion(fullfile(repoRoot, 'Cargo.toml'));
    tag = getenv('GITHUB_REF_NAME');

    if strlength(string(tag)) == 0
        tag = 'local';
    end

    fid = fopen(manifestFile, 'w');

    if fid < 0
        error('spf:manifestWriteFailed', 'Cannot write manifest file: %s', manifestFile);
    end

    cleanupObj = onCleanup(@() fclose(fid));
    fprintf(fid, 'name=spf_matlab\n');
    fprintf(fid, 'version=%s\n', version);
    fprintf(fid, 'tag=%s\n', tag);
    fprintf(fid, 'artifact=%s\n', artifactFile);
    fprintf(fid, 'bytes=%d\n', info.bytes);
    fprintf(fid, 'modified=%s\n', info.date);
    clear cleanupObj;
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
