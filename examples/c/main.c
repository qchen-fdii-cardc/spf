#include <stdio.h>
#include "../../include/spf.h"

int main(void)
{
    double re = 2500.0;
    double lam = spf_lambda(re);
    double dh = spf_hydraulic_diameter(0.20, 0.10);
    double kp = spf_kp_rect(re, 0.20, 0.10);

    printf("Re = %.1f\n", re);
    printf("lambda = %.6f\n", lam);
    printf("hydraulic diameter = %.6f\n", dh);
    printf("kp_rect = %.6f\n", kp);
    return 0;
}
