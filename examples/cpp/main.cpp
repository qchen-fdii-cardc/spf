#include <iostream>
#include "../../include/spf.h"

int main()
{
    const double re = 3000.0;
    const double lam = spf_lambda(re);
    const double dh = spf_hydraulic_diameter(0.30, 0.12);
    const double kp = spf_kp_rect(re, 0.30, 0.12);

    std::cout << "Re = " << re << '\n';
    std::cout << "lambda = " << lam << '\n';
    std::cout << "hydraulic diameter = " << dh << '\n';
    std::cout << "kp_rect = " << kp << '\n';
    return 0;
}
