' plot impulse response with bootstrap standard errors
' need to pass matrix returned by matbys= option of impulse
' checked 3/25/2004

' rsp = name of matrix returned by matbys = option
' upp = name of matrix of containing upper bounds for each column of rsp
' low = name of matrix of containing lower bounds for each column of rsp
' %gname = name for final combined graph

subroutine sub_bootirf(matrix rsp, matrix upp1, matrix low1,  matrix upp2, matrix low2, string %gname)

!hrz = @rows(rsp)
!k2 = @columns(rsp)

vector v
vector vbd

matrix(!hrz,5) tmp

%namelist = ""
' plot each graph separately 
for !c=1 to !k2
	' get point estimates
	v = @columnextract(rsp,!c)
	colplace(tmp,v,1)		
	' get bounds
	vbd = @columnextract(upp1,!c)
	colplace(tmp,vbd,2)		
	vbd = @columnextract(low1,!c)
	colplace(tmp,vbd,3)
      vbd = @columnextract(upp2,!c)
	colplace(tmp,vbd,4)		
	vbd = @columnextract(low2,!c)
	colplace(tmp,vbd,5)

	' make individual graph
	freeze(tmp_graph{!c}) tmp.line
	tmp_graph{!c}.option linepat	' need to set linepat
	tmp_graph{!c}.elem(1) lcolor(@rgb(0,87,174)) lpat(solid) linewidth(0.5) legend()
	tmp_graph{!c}.elem(2) lcolor(@rgb(220,130,56)) lpat(dash1) linewidth(0.5) legend("95% CI")
	tmp_graph{!c}.elem(3) lcolor(@rgb(220,130,56)) lpat(dash1) linewidth(0.5) legend()
      tmp_graph{!c}.elem(4) lcolor(@rgb(255,0,0)) lpat(dash7) linewidth(0.5) legend("90% CI")
	tmp_graph{!c}.elem(5) lcolor(@rgb(255,0,0)) lpat(dash7) linewidth(0.5) legend()
'	tmp_graph{!c}.legend(off)
'	tmp_graph{!c}.legend -display
	%namelist = %namelist + "tmp_graph" + @str(!c) + " "
next

' combine graphs
freeze({%gname}) {%namelist}

delete v vbd tmp {%namelist}

endsub


