function alias = load()
    %LOAD Load the SPF shared library for the current platform.
    %   alias = spf.load() loads the library once and returns the alias.

    alias = 'spf';

    if libisloaded(alias)
        return;
    end

    toolboxRoot = fileparts(fileparts(mfilename('fullpath')));
    headerPath = fullfile(toolboxRoot, 'include', 'spf.h');
    archName = computer('arch');

    if ispc
        libName = 'spf.dll';
    elseif ismac
        libName = 'libspf.dylib';
    else
        libName = 'libspf.so';
    end

    libPath = fullfile(toolboxRoot, 'bin', archName, libName);

    if ~isfile(headerPath)
        error('spf:headerNotFound', 'Header not found: %s', headerPath);
    end

    if ~isfile(libPath)
        error('spf:libraryNotFound', ['Library not found: %s\n' ...
                  'Run prepare_binaries in matlab_dist after cargo build --release.'], libPath);
    end

    loadlibrary(libPath, headerPath, 'alias', alias);
end
