﻿NM(ctf,"ctf",0,0,MT,MFD,DFD,MT,DAD)
ctf_f ctf_c;
MF(ctf_f){z.f=1;dim4 sp=z.s;sp[1]=r.r?r.s[r.r-1]:1;sp[0]=sp[1]?cnt(r)/sp[1]:1;
 sp[2]=sp[3]=1;z.r=2;z.s=sp;z.v=!cnt(z)?scl(0):array(r.v,z.s);}
DA(ctf_f){cat_c(z,l,r,e,ax);}
DF(ctf_f){z.f=1;if(l.r||r.r){cat_c(z,l,r,e,scl(scl(0)));R;}
 A a,b;cat_c(a,l,e);cat_c(b,r,e);cat_c(z,a,b,e);}
