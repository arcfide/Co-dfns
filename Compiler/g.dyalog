:Namespace G
  (⎕IO ⎕ML ⎕WX)←0 1 3 ⋄ A←##.A ⋄ R←##.R ⋄ pp←#.pp
  t←A.t ⋄ k←A.k ⋄ n←A.n ⋄ s←A.s ⋄ v←A.v ⋄ e←A.e
  FunM←A.FunM ⋄ ExpM←A.ExpM ⋄ AtmM←A.AtmM ⋄ FexS←A.FexS ⋄ FexM←A.FexM
  nl←⎕UCS 10
  hdr←'#include <math.h>',nl,'#include <dwa.h>',nl,'#include <dwa_fns.h>',nl
  hdr,←'int isinit=0;',nl
  flp←'LOCALP*z,LOCALP*l,LOCALP*r'
  do←{'{BOUND i;for(i=0;i<',(⍕⍺),';i++){',⍵,'}}',nl}
  tl←{('di'⍳⍵)⊃¨⊂('APLDOUB' 'double')('APLLONG' 'aplint32')}
  ged←{'LOCALP ',⍺,'[',(⍕≢∪n((ExpM∨AtmM)1↓⍵)⌿1↓⍵),'];',nl}
  ger←{(+/(ExpM∨AtmM)1↓⍵)do'regp(&',⍺,'[i]);'}
  gel←{'LOCALP*env[]={',(⊃,/(⊂'env0'),{',penv[',(⍕⍵),']'}¨⍳⊃s ⍵),'};',nl}
  ghi←{'void){',nl,'LOCALP *env[]={tenv};',nl,'tenv'ger ⍵}
  ght←{flp,'){',nl,('env0'ged ⍵),'LOCALP*env[]={env0,tenv};',nl,'env0'ger ⍵}
  ghn←{flp,',LOCALP*penv[]){',nl,('env0'ged ⍵),(gel ⍵),'env0'ger ⍵}
  gfi←'int oi=isinit;if(!isinit){Init();isinit=1;}',nl
  gfh←{'void EXPORT ',(⊃n ⍵),'(',((2⌊⊃s ⍵)⊃(ghi ⍵)(ght ⍵)(ghn ⍵)),⍺⊃'' gfi}
  gfr←{'z->p=zap(',((⊃⌽n 1↓⍵)vpp 0⌷⍉⊃⌽e 1↓⍵),');'}
  gff←{⍵{(gfr ⍺),'cutp(&env0[0]);',nl,⍵}⍣(1⌊⊃s⍵)⊢,(⍺⊃'}' 'isinit=oi;}'),nl}
  elt←{⍵≡⌊⍵:'APLLONG' ⋄ 'APLDOUB'} ⋄ eld←{⍵≡⌊⍵:'aplint32' ⋄ 'double'}
  vec←{(vsp ≢⍵),'getarray(',(elt⊃⍵),',',(⍕1<≢⍵),',','sp,',((⊃⍵)var 0⌷⍉⍺),');}',nl}
  vsp←{'{BOUND ',(1<⍵)⊃'*sp=NULL;'('sp[1]={',(⍕⍵),'};')}
  var←{(,'⍺')≡⍺:'l' ⋄ (,'⍵')≡⍺:'r' ⋄ '&env[',(⍕⊃⍵),'][',(⍕⊃⌽⍵),']'}
  vpp←{'(',(⍺ var ⍵),')->p'}
  dap←{⍺⍺,'*',⍺,'=ARRAYSTART(',((⊃n ⍵)vpp 0⌷⍉⊃e ⍵),');',nl}
  fil←{⊃,/⍵(⍺{⍺⍺,'[',(⍕⍵),']=',(((⍺<0)⊃'' '-'),⍕|⍺),';'})¨⍳≢⍵}
  Atmc←{((⊃e⍵)vec⊃v⍵),'{',('v'((eld⊃⊃v⍵)dap)⍵),('v'fil⊃v⍵),'}',nl}
  Atm0←{((⊃n ⍵)vpp 0⌷⍉⊃e ⍵),'=ref(',((⊃⊃v ⍵)vpp 1⌷⍉⊃e ⍵),');',nl}
  Expm←{f r←⊃v⍵ ⋄ ((⊃n⍵)r)(f R.gm ⍺)(⊃e⍵)[;0 2]}
  Expd←{l f r←⊃v⍵ ⋄ ((⊃n⍵)l r)(f R.gd ⍺)(⊃e⍵)[;0 1 3]}
  Expi←{a i←⊃v⍵ ⋄ ((⊃n⍵) a i)((,'[')R.gd ⍺)⊃e ⍵}
  Fexi←{(⊃n⍵)(##.MF.cat)('Fexim();',nl)}
  Fexf←{(⊃n⍵)('lft'R.gf⊃⊃v⍵)('NULL'R.gf⊃⊃v⍵)}
  Fexm←{f o←⊃v⍵ ⋄ (⊃n⍵)(o R.gomd f)(o R.gomm f)}
  Fexd←{(⊃n⍵)(##.OP.ptd)('Fexdm();',nl)}
  gex←{_←⍺⍺ ⋄ ⍎'⍺⍺ ',(⊃t⍵),(⍕⊃k⍵),' ⍵'}
  gfd←{0=≢f←FexS ⍵:0 3⍴⊂'' ⋄ {⍎(⊃t⍵),(⍕⊃k⍵),' ⍵'}⍤1⊢f} ⋄ gdf←{(~FexM ⍵)⌿⍵}
  gcf←{⍵,(⍵⍵ gfh ⍺),(⊃,/(⊂(⍺⍺⍪gfd 1↓⍺)gex)⍤1⊢gdf 1↓⍺),(⍵⍵ gff ⍺),nl}
  gtf←⍉∘⍪0 'Fun' 0 'Init',4↓∘,1↑⊢
  gct←{b←gdf⊃⍵ ⋄ ⊂((gtf b)⍪1↓b)((0 3⍴⊂'')gcf 0)hdr,('tenv'ged b),gfs ⍵}
  gfs←{⊃,/{'void EXPORT ',(⊃n 1↑⍵),'(',flp,((¯1+⊃s 1↑⍵)⊃');' ',LOCALP*penv[]);'),nl}¨1↓⍵}
  gc←{⊃(gfd⊃⍵)gcf 1/⌽(gct ⍵),1↓⍵}(1,1↓FunM)⊂[0]⊢
:EndNamespace 
