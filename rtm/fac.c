﻿NM(fac,"fac",1,1,DID,MFD,DFD,MT ,DAD)
DEFN(fac)
ID(fac,1,s32)
SMF(fac,z.v=factorial(rv.as(f64)))
SF(fac,arr lvf=lv.as(f64);arr rvf=rv.as(f64);
 z.v=exp(lgamma(1+rvf)-(lgamma(1+lvf)+lgamma(1+rvf-lvf))))