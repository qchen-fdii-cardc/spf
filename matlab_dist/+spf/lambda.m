function value = lambda(re)
    %LAMBDA Compute Darcy friction factor from Reynolds number.

    alias = spf.load();
    value = calllib(alias, 'spf_lambda', double(re));
end
