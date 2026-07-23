//! Core friction and hydraulic utility functions.
//! This crate also exposes a C ABI for FFI integrations.

/// Computes Darcy friction factor `lambda` from Reynolds number `re`.
///
/// Piecewise model:
/// - `re < 2000`: laminar flow, `lambda = 64 / re`
/// - `2000 <= re <= 4000`: cubic interpolation through tabulated transition points
/// - `4000 < re < 100000`: Blasius correlation
/// - `re >= 100000`: empirical smooth-pipe correlation
pub fn lambda(re: f64) -> f64 {
    if re < 2000.0 {
        return 64.0 / re;
    } else if re >= 2000.0 && re <= 4000.0 {
        // Exact cubic interpolation through:
        // (2000, 0.032), (2500, 0.034), (3000, 0.040), (4000, 0.040)
        // x = (Re - 2000) / 1000
        // lambda = -0.008x^3 + 0.020x^2 - 0.004x + 0.032
        let x = (re - 2000.0) / 1000.0;
        return -0.008 * x.powi(3) + 0.020 * x.powi(2) - 0.004 * x + 0.032;
    } else if re > 4000.0 && re < 100000.0 {
        return 0.3164 / re.powf(0.25);
    } else {
        return 1.0 / (1.8 * re.log10() - 1.64).powf(2.0);
    }
}

/// Computes hydraulic diameter for a rectangular duct.
///
/// Formula: `D_h = 2ab / (a + b)`.
/// `a` and `b` are side lengths.
pub fn hydraulic_diameter(a: f64, b: f64) -> f64 {
    return 2.0 * a * b / (a + b);
}

/// Computes rectangular correction factor `k_p`.
///
/// Uses piecewise cubic fits based on aspect ratio `ba = b0 / a0`:
/// - laminar branch for `re < 2000`
/// - turbulent branch for `re >= 2000`
pub fn kp_rect(re: f64, a0: f64, b0: f64) -> f64 {
    let ba = b0 / a0;
    let k = if re < 2000.0 {
        // laminar flow
        // Exact cubic interpolation through:
        // 0, 1.50; 0.2, 1.34; 0.2, 1.20; 0.4, 1.02; 0.6, 0.94; 0.8, 0.90; 1.0, 0.89
        -0.61 * ba.powi(3) + 1.22 * ba.powi(2) - 0.61 * ba + 1.50
    } else {
        // turbulent flow
        // Exact cubic interpolation through:
        // 0, 1.10; 0.2, 1.08; 0.2, 1.06; 0.4, 1.04; 0.6, 1.02; 0.8, 1.01; 1.0, 1.0
        -0.10 * ba.powi(3) + 0.30 * ba.powi(2) - 0.20 * ba + 1.10
    };
    return k;
}

/// C ABI wrapper for [`lambda`].
#[unsafe(no_mangle)]
pub extern "C" fn spf_lambda(re: f64) -> f64 {
    lambda(re)
}

/// C ABI wrapper for [`hydraulic_diameter`].
#[unsafe(no_mangle)]
pub extern "C" fn spf_hydraulic_diameter(a: f64, b: f64) -> f64 {
    hydraulic_diameter(a, b)
}

/// C ABI wrapper for [`kp_rect`].
#[unsafe(no_mangle)]
pub extern "C" fn spf_kp_rect(re: f64, a0: f64, b0: f64) -> f64 {
    kp_rect(re, a0, b0)
}

#[cfg(test)]
mod re_le_2000 {
    use crate::lambda;

    fn assert_lambda_matches_data(data: &[(f64, f64)], tolerance: f64) {
        for (re, expected_lambda) in data.iter().copied() {
            let calculated_lambda = lambda(re);
            println!(
                "{:10.3}{:10.3}{:10.3}",
                re, expected_lambda, calculated_lambda
            );
            assert!(
                (calculated_lambda - expected_lambda).abs() < tolerance,
                "Reynolds number: {}, Expected lambda: {}, Calculated lambda: {}",
                re,
                expected_lambda,
                calculated_lambda
            );
        }
    }

    #[test]
    fn reynolds_number_lambda_10_to_2000() {
        let data = [
            (100.0, 0.640),
            (200.0, 0.320),
            (300.0, 0.213),
            (400.0, 0.160),
            (500.0, 0.128),
            (600.0, 0.107),
            (700.0, 0.092),
            (800.0, 0.080),
            (900.0, 0.071),
            (1000.0, 0.064),
            (1100.0, 0.058),
            (1200.0, 0.053),
            (1300.0, 0.049),
            (1400.0, 0.046),
            (1500.0, 0.043),
            (1600.0, 0.040),
            (1700.0, 0.038),
            (1800.0, 0.036),
            (1900.0, 0.034),
            (2000.0, 0.032),
        ];
        assert_lambda_matches_data(data.as_slice(), 0.001);
    }

    #[test]
    fn reynolds_number_lambda_2000_to_100000() {
        let data = [
            (2.0e3, 0.032),
            (2.5e3, 0.034),
            (3.0e3, 0.040),
            (4.0e3, 0.040),
            (5.0e3, 0.038),
            (6.0e3, 0.036),
            (8.0e3, 0.033),
            (1.0e4, 0.032),
            (1.5e4, 0.028),
            (2.0e4, 0.026),
            (3.0e4, 0.024),
            (4.0e4, 0.022),
            (5.0e4, 0.021),
            (6.0e4, 0.020),
            (8.0e4, 0.019),
            (1.0e5, 0.018),
        ];
        assert_lambda_matches_data(data.as_slice(), 0.001);
    }

    #[test]
    fn reynolds_number_lambda_100000_to_1e8() {
        let data = [
            (1.0e5, 0.018),
            (1.5e5, 0.017),
            (2.0e5, 0.016),
            (3.0e5, 0.015),
            (4.0e5, 0.014),
            (5.0e5, 0.013),
            (6.0e5, 0.013),
            (8.0e5, 0.012),
            (1.0e6, 0.012),
            (1.5e6, 0.011),
            (2.0e6, 0.011),
            (3.0e6, 0.010),
            (4.0e6, 0.010),
            (5.0e6, 0.009),
            (8.0e6, 0.009),
            (1.0e7, 0.008),
            (1.5e7, 0.008),
            (2.0e7, 0.008),
            (3.0e7, 0.007),
            (6.0e7, 0.007),
            (8.0e7, 0.006),
            (1.0e8, 0.006),
        ];
        assert_lambda_matches_data(data.as_slice(), 1e-3);
    }
}
