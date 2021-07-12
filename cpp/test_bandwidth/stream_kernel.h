inline void stream_load(void* start_addr)
{
#ifdef X86_64
    // AVX2 insts
    asm volatile("movdqa 0(%0), %%xmm0\n\t"
                "movdqa 64(%0), %%xmm1\n\t"
                "movdqa 128(%0), %%xmm2\n\t"
                "movdqa 192(%0), %%xmm3\n\t"
                "movdqa 256(%0), %%xmm4\n\t"
                "movdqa 320(%0), %%xmm5\n\t"
                "movdqa 384(%0), %%xmm6\n\t"
                "movdqa 448(%0), %%xmm7\n\t"
                "movdqa 512(%0), %%xmm0\n\t"
                "movdqa 576(%0), %%xmm1\n\t"
                "movdqa 640(%0), %%xmm2\n\t"
                "movdqa 704(%0), %%xmm3\n\t"
                "movdqa 768(%0), %%xmm4\n\t"
                "movdqa 832(%0), %%xmm5\n\t"
                "movdqa 896(%0), %%xmm6\n\t"
                "movdqa 960(%0), %%xmm7\n\t"
                "movdqa 1024(%0), %%xmm0\n\t"
                "movdqa 1088(%0), %%xmm1\n\t"
                "movdqa 1152(%0), %%xmm2\n\t"
                "movdqa 1216(%0), %%xmm3\n\t"
                "movdqa 1280(%0), %%xmm4\n\t"
                "movdqa 1344(%0), %%xmm5\n\t"
                "movdqa 1408(%0), %%xmm6\n\t"
                "movdqa 1472(%0), %%xmm7\n\t"
                "movdqa 1536(%0), %%xmm0\n\t"
                "movdqa 1600(%0), %%xmm1\n\t"
                "movdqa 1664(%0), %%xmm2\n\t"
                "movdqa 1728(%0), %%xmm3\n\t"
                "movdqa 1792(%0), %%xmm4\n\t"
                "movdqa 1856(%0), %%xmm5\n\t"
                "movdqa 1920(%0), %%xmm6\n\t"
                "movdqa 1984(%0), %%xmm7\n\t"
                :
                : "r"(start_addr)
                );

#endif

#ifdef ARMV8
        asm volatile("ldr r1, 0(%0)\n\t"
                    "ldr r1, 64(%0)\n\t"
                    "ldr r1, 128(%0)\n\t"
                    "ldr r1, 192(%0)\n\t"
                    "ldr r1, 256(%0)\n\t"
                    "ldr r1, 320(%0)\n\t"
                    "ldr r1, 384(%0)\n\t"
                    "ldr r1, 448(%0)\n\t"
                    "ldr r1, 512(%0)\n\t"
                    "ldr r1, 576(%0)\n\t"
                    "ldr r1, 640(%0)\n\t"
                    "ldr r1, 704(%0)\n\t"
                    "ldr r1, 768(%0)\n\t"
                    "ldr r1, 832(%0)\n\t"
                    "ldr r1, 896(%0)\n\t"
                    "ldr r1, 960(%0)\n\t"
                    "ldr r1, 1024(%0)\n\t"
                    "ldr r1, 1088(%0)\n\t"
                    "ldr r1, 1152(%0)\n\t"
                    "ldr r1, 1216(%0)\n\t"
                    "ldr r1, 1280(%0)\n\t"
                    "ldr r1, 1344(%0)\n\t"
                    "ldr r1, 1408(%0)\n\t"
                    "ldr r1, 1472(%0)\n\t"
                    "ldr r1, 1536(%0)\n\t"
                    "ldr r1, 1600(%0)\n\t"
                    "ldr r1, 1664(%0)\n\t"
                    "ldr r1, 1728(%0)\n\t"
                    "ldr r1, 1792(%0)\n\t"
                    "ldr r1, 1856(%0)\n\t"
                    "ldr r1, 1920(%0)\n\t"
                    "ldr r1, 1984(%0)\n\t"
                    :
                    : "r"(start_addr)
                    );
#endif

#ifdef RISCV64
        asm volatile("ld t1, 0(%0)\n\t"
                    "ld t1, 64(%0)\n\t"
                    "ld t1, 128(%0)\n\t"
                    "ld t1, 192(%0)\n\t"
                    "ld t1, 256(%0)\n\t"
                    "ld t1, 320(%0)\n\t"
                    "ld t1, 384(%0)\n\t"
                    "ld t1, 448(%0)\n\t"
                    "ld t1, 512(%0)\n\t"
                    "ld t1, 576(%0)\n\t"
                    "ld t1, 640(%0)\n\t"
                    "ld t1, 704(%0)\n\t"
                    "ld t1, 768(%0)\n\t"
                    "ld t1, 832(%0)\n\t"
                    "ld t1, 896(%0)\n\t"
                    "ld t1, 960(%0)\n\t"
                    "ld t1, 1024(%0)\n\t"
                    "ld t1, 1088(%0)\n\t"
                    "ld t1, 1152(%0)\n\t"
                    "ld t1, 1216(%0)\n\t"
                    "ld t1, 1280(%0)\n\t"
                    "ld t1, 1344(%0)\n\t"
                    "ld t1, 1408(%0)\n\t"
                    "ld t1, 1472(%0)\n\t"
                    "ld t1, 1536(%0)\n\t"
                    "ld t1, 1600(%0)\n\t"
                    "ld t1, 1664(%0)\n\t"
                    "ld t1, 1728(%0)\n\t"
                    "ld t1, 1792(%0)\n\t"
                    "ld t1, 1856(%0)\n\t"
                    "ld t1, 1920(%0)\n\t"
                    "ld t1, 1984(%0)\n\t"
                    :
                    : "r"(start_addr)
                    );
#endif
}

inline void stream_store(void* start_addr)
{

#ifdef X86_64
    // AVX2 insts
    asm volatile("movdqa %%xmm0, 0(%0)\n\t"
                "movdqa %%xmm1, 64(%0)\n\t"
                "movdqa %%xmm2, 128(%0)\n\t"
                "movdqa %%xmm3, 192(%0)\n\t"
                "movdqa %%xmm4, 256(%0)\n\t"
                "movdqa %%xmm5, 320(%0)\n\t"
                "movdqa %%xmm6, 384(%0)\n\t"
                "movdqa %%xmm7, 448(%0)\n\t"
                "movdqa %%xmm0, 512(%0)\n\t"
                "movdqa %%xmm1, 576(%0)\n\t"
                "movdqa %%xmm2, 640(%0)\n\t"
                "movdqa %%xmm3, 704(%0)\n\t"
                "movdqa %%xmm4, 768(%0)\n\t"
                "movdqa %%xmm5, 832(%0)\n\t"
                "movdqa %%xmm6, 896(%0)\n\t"
                "movdqa %%xmm7, 960(%0)\n\t"
                "movdqa %%xmm0, 1024(%0)\n\t"
                "movdqa %%xmm1, 1088(%0)\n\t"
                "movdqa %%xmm2, 1152(%0)\n\t"
                "movdqa %%xmm3, 1216(%0)\n\t"
                "movdqa %%xmm4, 1280(%0)\n\t"
                "movdqa %%xmm5, 1344(%0)\n\t"
                "movdqa %%xmm6, 1408(%0)\n\t"
                "movdqa %%xmm7, 1472(%0)\n\t"
                "movdqa %%xmm0, 1536(%0)\n\t"
                "movdqa %%xmm1, 1600(%0)\n\t"
                "movdqa %%xmm2, 1664(%0)\n\t"
                "movdqa %%xmm3, 1728(%0)\n\t"
                "movdqa %%xmm4, 1792(%0)\n\t"
                "movdqa %%xmm5, 1856(%0)\n\t"
                "movdqa %%xmm6, 1920(%0)\n\t"
                "movdqa %%xmm7, 1984(%0)\n\t"
                :
                : "r"(start_addr)
                );

#endif

#ifdef ARMV8
        asm volatile("sdr r1, 0(%0)\n\t"
                    "sdr r1, 64(%0)\n\t"
                    "sdr r1, 128(%0)\n\t"
                    "sdr r1, 192(%0)\n\t"
                    "sdr r1, 256(%0)\n\t"
                    "sdr r1, 320(%0)\n\t"
                    "sdr r1, 384(%0)\n\t"
                    "sdr r1, 448(%0)\n\t"
                    "sdr r1, 512(%0)\n\t"
                    "sdr r1, 576(%0)\n\t"
                    "sdr r1, 640(%0)\n\t"
                    "sdr r1, 704(%0)\n\t"
                    "sdr r1, 768(%0)\n\t"
                    "sdr r1, 832(%0)\n\t"
                    "sdr r1, 896(%0)\n\t"
                    "sdr r1, 960(%0)\n\t"
                    "sdr r1, 1024(%0)\n\t"
                    "sdr r1, 1088(%0)\n\t"
                    "sdr r1, 1152(%0)\n\t"
                    "sdr r1, 1216(%0)\n\t"
                    "sdr r1, 1280(%0)\n\t"
                    "sdr r1, 1344(%0)\n\t"
                    "sdr r1, 1408(%0)\n\t"
                    "sdr r1, 1472(%0)\n\t"
                    "sdr r1, 1536(%0)\n\t"
                    "sdr r1, 1600(%0)\n\t"
                    "sdr r1, 1664(%0)\n\t"
                    "sdr r1, 1728(%0)\n\t"
                    "sdr r1, 1792(%0)\n\t"
                    "sdr r1, 1856(%0)\n\t"
                    "sdr r1, 1920(%0)\n\t"
                    "sdr r1, 1984(%0)\n\t"
                    :
                    : "r"(start_addr)
                    );
#endif

#ifdef RISCV64
        asm volatile("sd t1, 0(%0)\n\t"
                    "sd t1, 64(%0)\n\t"
                    "sd t1, 128(%0)\n\t"
                    "sd t1, 192(%0)\n\t"
                    "sd t1, 256(%0)\n\t"
                    "sd t1, 320(%0)\n\t"
                    "sd t1, 384(%0)\n\t"
                    "sd t1, 448(%0)\n\t"
                    "sd t1, 512(%0)\n\t"
                    "sd t1, 576(%0)\n\t"
                    "sd t1, 640(%0)\n\t"
                    "sd t1, 704(%0)\n\t"
                    "sd t1, 768(%0)\n\t"
                    "sd t1, 832(%0)\n\t"
                    "sd t1, 896(%0)\n\t"
                    "sd t1, 960(%0)\n\t"
                    "sd t1, 1024(%0)\n\t"
                    "sd t1, 1088(%0)\n\t"
                    "sd t1, 1152(%0)\n\t"
                    "sd t1, 1216(%0)\n\t"
                    "sd t1, 1280(%0)\n\t"
                    "sd t1, 1344(%0)\n\t"
                    "sd t1, 1408(%0)\n\t"
                    "sd t1, 1472(%0)\n\t"
                    "sd t1, 1536(%0)\n\t"
                    "sd t1, 1600(%0)\n\t"
                    "sd t1, 1664(%0)\n\t"
                    "sd t1, 1728(%0)\n\t"
                    "sd t1, 1792(%0)\n\t"
                    "sd t1, 1856(%0)\n\t"
                    "sd t1, 1920(%0)\n\t"
                    "sd t1, 1984(%0)\n\t"
                    :
                    : "r"(start_addr)
                    );
#endif
}