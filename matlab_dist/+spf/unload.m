function unload()
    %UNLOAD Unload the SPF shared library if currently loaded.

    alias = 'spf';

    if libisloaded(alias)
        unloadlibrary(alias);
    end

end
