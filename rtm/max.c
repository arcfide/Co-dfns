﻿NM(max,"max",1,1,DID,MFD,DFD,MT ,DAD)
max_f max_c;
ID(max,-DBL_MAX,f64)
MF(max_f){z.s=r.s;z.v=ceil(r.v).as(r.v.type());}
SF(max,z.v=max(lv,rv))

