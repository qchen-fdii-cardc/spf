function value = kpRect(re, a0, b0)
    %KPRECT Compute rectangular correction factor.

    alias = spf.load();
    value = calllib(alias, 'spf_kp_rect', double(re), double(a0), double(b0));
end
