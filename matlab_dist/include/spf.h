#ifndef SPF_H
#define SPF_H

#ifdef __cplusplus
extern "C"
{
#endif

    double spf_lambda(double re);
    double spf_hydraulic_diameter(double a, double b);
    double spf_kp_rect(double re, double a0, double b0);

#ifdef __cplusplus
}
#endif

#endif
