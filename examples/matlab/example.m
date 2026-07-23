function example()
    root = fileparts(fileparts(fileparts(mfilename('fullpath'))));

    if ispc
        libName = 'spf.dll';
    elseif ismac
        libName = 'libspf.dylib';
    else
        libName = 'libspf.so';
    end

    libPath = fullfile(root, 'target', 'release', libName);
    headerPath = fullfile(root, 'include', 'spf.h');

    if ~isfile(libPath)
        error('Dynamic library not found: %s', libPath);
    end

    alias = 'spf';
    if ~libisloaded(alias)
        loadlibrary(libPath, headerPath, 'alias', alias);
    end

    re = 2500.0;
    lambda = calllib(alias, 'spf_lambda', re);
    dh = calllib(alias, 'spf_hydraulic_diameter', 0.2, 0.1);
    kp = calllib(alias, 'spf_kp_rect', re, 0.2, 0.1);

    fprintf('Re = %.1f\n', re);
    fprintf('lambda = %.6f\n', lambda);
    fprintf('hydraulic diameter = %.6f\n', dh);
    fprintf('kp_rect = %.6f\n', kp);

    unloadlibrary(alias);
end
