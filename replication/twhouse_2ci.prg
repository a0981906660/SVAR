
%path = @runpath
cd %path
include sub_bootirf_new2.prg
'=========  Setting =========================
!byr = 0 ' 0 if by variable, 1 if by shock 
!v = 7    ' The !v-th variable, for  !byr = 0
!s = 1    ' The !s-th shock, for !byr = 1
!hrz = 40                 '      response horizons for IRF
!reps = 1500            '      # of replications in bootstrap
!maxlag = 4      
!eviews = 14
' 14 if EVews 12
'  2 if EVews 13
!info = 1
'1 if  bic, 2 aic, 3 if p=4
!hp =  1    ' 1 if baseline, 2 if prie to income ratio, 3 if nomial, 4 if Taipei 
%bootname = "sp"  
!rescale = 1         ' 0 if no rescaled, 1 if recsacled
%rescale = "1 3"  ' the  i-th shock to be rescaled
'===========  Data ======================
wfcreate(wf=twhouse)  q 1991:1 2021:3
read(c3,s=qdata) data_quarterly_concise.xls _
R mr loanall loan1 loan2 loan3 cci hp_tw1 hp_tpe1 sent CPI rGDP Ccost Pop_Tw2

'金融業隔夜拆款加權平均利率	
'五大行庫平均房貸利率	
'消費者貸款
'消費者貸款-購置住宅貸款	
'消費者貸款-房屋修繕貸款	
'建築貸款	
'消費者信心指數（未來半年購買耐久性財貨時機）	
'信義房價指數 （台灣）	
'信義房價指數 （臺北）
'Sentiment Index
' CPI
'RGDP
' CCost 營造工程物價指數
'台灣總人口（千人）	

read(b5,s=NGDP) NominalGDP.xls _
NGDP

genr loanall = loanall/3 
genr loanratio = loan1/ngdp
genr rhp = hp_tw1/cpi
genr rmr = mr - 100*log(cpi/cpi(-4))
genr pir = log(hp_tw1) - (log(NGDP) - log(pop_tw2*1000))  '



sent.displayname Housing Market Sentiment 
cci.displayname Consumer Confidence Index (Sub-index of Durable Purchasing Decisions )
group sentcci sent cci
freeze(sentcciplot) sentcci.line
sentcciplot.axis overlap
sentcciplot.setelem(2) axis(r)
sentcciplot.axis(r) range(minmax)
sentcciplot.axis(l) range(minmax)
sentcciplot.options linepat

freeze(TWHP) hp_tw1.line
TWHP.delete text

%vname = "rgdp ccost rhp cci cpi hp_tw1"


For %x {%vname}
genr L{%x} = log({%x})
next


group GCgroup SENT CCI
freeze(GCtable) GCgroup.cause(4)


genr Y1 = R  ' 隔夜拆款利率(%)
genr Y2 = lrgdp
genr Y3 = rmr
genr Y4 = loanratio
genr Y5 = lccost  ' CCost 營造工程物價指數
genr Y6 = sent
if !hp = 1 then
genr Y7 = lrhp   '信義房價指數(台灣)  Real House Prices
endif
if !hp = 2 then
genr Y7 = pir   
endif
if !hp = 3 then
genr Y7 = lhp_tw1   
endif
if !hp = 4 then
genr Y7 = log(hp_tpe1) - log(cpi)   
endif



Y1.displayname Overnight Rate
Y2.displayname Real GDP (log)
Y3.displayname Real Mortgage Rate 
Y4.displayname Housing Loan Ratio 
Y5.displayname Construction Price Index (log)
Y6.displayname Housing Market Sentiment 
Y7.displayname Real House Price (log)

group vargroup Y1 Y2 Y3 Y4 Y5 Y6 Y7
%imp = "Y1 Y2 Y3 Y4 Y5 Y6 Y7"
%resp = "Y1 Y2 Y3 Y4 Y5 Y6 Y7"
vector(2) coverp
coverp.fill 0.95, 0.90 

var test.ls 1 5 vargroup
freeze(lagselection1) test.laglen(!maxlag, vname = vlag)
if !info = 1 then
!varlag = vlag(4)
endif
if !info = 2 then
!varlag = vlag(3)
endif
if !info = 3 then
!varlag = 4
endif

 ' Generate VAR estimation
	var var_hp.ls 1 !varlag vargroup
!vn = var_hp.@neqn

for !kkk = 1 to 2 
!ci = coverp(!kkk)

freeze(imp) var_hp.impulse(!hrz,se=boot, bs={%bootname}, cilevels=!ci,rep=!reps,cimat=bci,matbys=rsp) {%resp} @ {%imp}



if !eviews =14 then
matrix bci=bci_bsci
endif

' bci is matbys

for !i=1 to !vn ' !i shocks
!j = 1 + !vn*(!i-1)
!k = !vn*!i
matrix rsp_!i =  @subextract(rsp,1,!j,!hrz,!k)
next

for !i = 1 to !vn    ' !i for shocks
!j = 1 + 2*!vn*(!i-1)
!k = 2*!vn*!i
matrix bci_!i =  @subextract(bci,1,!j,!hrz,!k)
next

' rescale the IRF
if !rescale = 1 then
for %1 {%rescale}
!shock_{%1} = rsp_{%1}({%1},{%1})
rsp_{%1} = rsp_{%1}*(-1)/!shock_{%1}
bci_{%1} = bci_{%1}*(-1)/!shock_{%1}
next
endif

matrix(!hrz,!vn) rsp_br 
matrix(!hrz,!vn) bupper_br
matrix(!hrz,!vn) blower_br
matrix(!hrz,!vn) rsp_bs 
matrix(!hrz,!vn) bupper_bs
matrix(!hrz,!vn) blower_bs


if !byr = 0 then
%x="br"

for !i=1 to !hrz
   for !j=1 to !vn   ' !j for shock
          rsp_br(!i,!j) = rsp_!j(!i,!v)
          blower_br(!i,!j) = bci_!j(!i,2*!v-1)
          bupper_br(!i,!j) =bci_!j(!i,2*!v)
   next
next

else
%x="bs"
         rsp_bs = rsp_!s
for !i=1 to !hrz
  for !j = 1 to !vn
         blower_bs(!i,!j) = bci_!s(!i,2*!j-1)
         bupper_bs(!i,!j) =bci_!s(!i,2*!j)
  next
next
endif


matrix rsp_{%x}_!kkk = rsp_{%x}
matrix bupper_{%x}_!kkk = bupper_{%x}
matrix blower_{%x}_!kkk = blower_{%x}
delete rsp 
delete bci
delete imp
next

call sub_bootirf(rsp_{%x}_1, bupper_{%x}_1, blower_{%x}_1, bupper_{%x}_2, blower_{%x}_2,"IRF")


IRF.align(2,2,1.5)



if !byr = 1 then
  IRF.addtext(0.25,-0.5,font(Calibri,20,-b,-i,-u,-s)) Overnight Rate 
  IRF.addtext(8.15,-0.5,font(Calibri,20,-b,-i,-u,-s)) Ral GDP 
  IRF.addtext(0.25,3.96,font(Calibri,20,-b,-i,-u,-s)) Real Mortgage Rate
  IRF.addtext(8.15,3.96,font(Calibri,20,-b,-i,-u,-s)) Housing Loan
  IRF.addtext(0.25,8.50,font(Calibri,20,-b,-i,-u,-s)) Construction Price 
  IRF.addtext(8.15,8.50,font(Calibri,20,-b,-i,-u,-s)) Housing Market Sentiment 
  IRF.addtext(0.25,13.03,font(Calibri,20,-b,-i,-u,-s))  Real House Price
endif 

if !byr = 0 then
  IRF.addtext(0.25,-0.5,font(Calibri,20,-b,-i,-u,-s)) Monetary Policy Shock
  IRF.addtext(8.15,-0.5,font(Calibri,20,-b,-i,-u,-s)) Real Output Shock
  IRF.addtext(0.25,3.96,font(Calibri,20,-b,-i,-u,-s)) User Cost Shock 
  IRF.addtext(8.15,3.96,font(Calibri,20,-b,-i,-u,-s)) Credit Shock 
  IRF.addtext(0.25,8.50,font(Calibri,20,-b,-i,-u,-s)) Construction Cost Shock
  IRF.addtext(8.15,8.50,font(Calibri,20,-b,-i,-u,-s)) Sentiment Shock
  IRF.addtext(0.25,13.03,font(Calibri,20,-b,-i,-u,-s)) House Price Shock
endif


