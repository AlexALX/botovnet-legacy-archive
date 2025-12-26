#define VIP_FLAG_ALL 0	// everyone
#define VIP_FLAG_A (1<<0)	// vips slots (работает с флагом z)
#define VIP_FLAG_B (1<<1)	// ip access (ipaccess.ini, работает с флагом z)
#define VIP_FLAG_C (1<<2)	// привилегии випа (не работает с флагом z)
#define VIP_FLAG_D (1<<3)	// голосования (не работает с флагом z)
#define VIP_FLAG_E (1<<4)	// flag "e"
#define VIP_FLAG_F (1<<5)	// flag "f"
#define VIP_FLAG_G (1<<6)	// flag "g"
#define VIP_FLAG_H (1<<7)	// flag "h"
#define VIP_FLAG_I (1<<8)	// flag "i"
#define VIP_FLAG_J (1<<9)	// flag "j"
#define VIP_FLAG_K (1<<10)	// flag "k"
#define VIP_FLAG_L (1<<11)	// flag "l"
#define VIP_FLAG_M (1<<12)	// flag "m"
#define VIP_FLAG_N (1<<13)	// flag "n"
#define VIP_FLAG_O (1<<14)	// flag "o"
#define VIP_FLAG_P (1<<15)	// flag "p"
#define VIP_FLAG_Q (1<<16)	// flag "q"
#define VIP_FLAG_R (1<<17)	// flag "r"
#define VIP_FLAG_S (1<<18)	// flag "s"
#define VIP_FLAG_T (1<<19)	// flag "t"
#define VIP_FLAG_U (1<<20)	// бесплатный вип (системный)
#define VIP_FLAG_Y (1<<21)	// flag "y"
#define VIP_FLAG_Z (1<<25)	// reserved to no flags VIP user

native is_user_vip(index);

native get_vip_flags(index);

native get_sysvip_flags(index);

native get_vip_options(index);