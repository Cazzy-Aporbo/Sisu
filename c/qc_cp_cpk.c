/* Compile: gcc qc_cp_cpk.c -lm -o cpck
   Run:     ./cpck LSL USL mean stdev
   Example: ./cpck 9.5 10.5 10.1 0.15
*/
#include <stdio.h>
#include <math.h>
int main(int argc, char** argv) {
    if (argc < 5) { printf("usage: %s LSL USL mean stdev\n", argv[0]); return 1; }
    double LSL=atof(argv[1]), USL=atof(argv[2]), mu=atof(argv[3]), s=atof(argv[4]);
    if (s<=0 || USL<=LSL){ printf("bad inputs\n"); return 1; }
    double Cp  = (USL - LSL) / (6.0*s);
    double Cpu = (USL - mu) / (3.0*s);
    double Cpl = (mu - LSL) / (3.0*s);
    double Cpk = fmin(Cpu, Cpl);
    printf("Cp=%.3f  Cpk=%.3f  (Cpu=%.3f, Cpl=%.3f)\n", Cp, Cpk, Cpu, Cpl);
    if (Cpk >= 1.33) puts("✅ Capable");
    else if (Cpk >= 1.0) puts("⚠️  Marginal");
    else puts("❌ Not capable");
    return 0;
}
