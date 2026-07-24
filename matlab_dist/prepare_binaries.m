function prepare_binaries()
    %PREPARE_BINARIES Copy built SPF binary and header into toolbox layout.
    %   Run this after: cargo build --release

    toolboxRoot = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(toolboxRoot);
    archName = computer('arch');

    if ispc
        libName = 'spf.dll';
    elseif ismac
        libName = 'libspf.dylib';
    else
        libName = 'libspf.so';
    end

    sourceLib = fullfile(repoRoot, 'target', 'release', libName);
    sourceHeader = fullfile(repoRoot, 'include', 'spf.h');

    if ~isfile(sourceLib)
        error('spf:buildMissing', ['Built library not found: %s\n' ...
                  'Build first with cargo build --release.'], sourceLib);
    end

    if ~isfile(sourceHeader)
        error('spf:headerMissing', 'Header not found: %s', sourceHeader);
    end

    outBinDir = fullfile(toolboxRoot, 'bin', archName);
    outIncludeDir = fullfile(toolboxRoot, 'include');

    if ~exist(outBinDir, 'dir')
        mkdir(outBinDir);
    end

    if ~exist(outIncludeDir, 'dir')
        mkdir(outIncludeDir);
    end

    copyfile(sourceLib, fullfile(outBinDir, libName));
    copyfile(sourceHeader, fullfile(outIncludeDir, 'spf.h'));

    fprintf('Copied library to: %s\n', fullfile(outBinDir, libName));
    fprintf('Copied header to: %s\n', fullfile(outIncludeDir, 'spf.h'));
end
