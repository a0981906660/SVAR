###### VAR/SVAR 家闽祘Α
rm(list=ls())
Path = "c:\\VAR\\"              # 砞﹚隔畖
setwd(Path)
source("VARsource.R")           # 弄 VARsource.R 郎

        ###### 弄戈:材 1 彻  ######
file = "TWData.csv"
data = read.csv(file = file, header = TRUE)
By   = as.matrix(data[,2:4])

        #----- 家砞﹚ -----#
VAR.P = 2                       # 程辅兜计
CONST = TRUE                    # 琌Τ盽计兜
Y     = VAR.Y(By, VAR.P)        # 砞﹚ Y
X     = VAR.X(By, VAR.P)        # 砞﹚ X
ddY   = VAR.ddY(By, VAR.P)      # 砞﹚ ddY
ddX   = VAR.ddX(By, VAR.P)      # 砞﹚ ddX

        ###### 把计︳璸:材 2 彻 ######
(Coef.OLS    = VAR.OLS(Y, X, CONST)                  )
(Coef.EbyE   = VAR.EbyE(ddY, ddX, CONST)             )
(Sigma.OLS   = VAR.Sigma.OLS(Y, X, Coef.OLS, CONST)  )
(ddSigma.OLS = VAR.ddSigma.OLS(ddY, ddX, CONST)      )
(Sigma.MLE   = VAR.Sigma.MLE(Y, X, Coef.OLS, CONST)  )
(ddSigma.MLE = VAR.ddSigma.MLE(ddY, ddX, CONST)      )

        ###### 把计︳璸:材 3 彻 ######
A.Mat  = matrix(1, 3, 7)        # 砞﹚êㄇ把计璶
A.Mat[2,3] = 0; A.Mat[2,6] = 0;
A.Mat[3,2] = 0; A.Mat[3,5] = 0;
R = VAR.A2R(A.Mat)              # 砞﹚ R
r = matrix(0, 21, 1)            # 砞﹚ r

        #-----  OLS ︳璸把计 -----#
Beta = VAR.ROLS(Y, X, R, r, CONST)
beta = as.vector(Beta)
(RCoef.ROLS = matrix(beta, 3, 7)                     )

        #-----  FGLS ︳璸把计 -----#
Sigma.OLS = VAR.Sigma.OLS(Y, X, Coef.OLS, CONST)
Beta = VAR.RFGLS(Y, X, R, r, Sigma.OLS, CONST)
beta = as.vector(Beta)
(RCoef.RFGLS = matrix(beta, 3, 7)                    )

        #-----  MLE ︳璸把计 -----#
Sigma.MLE = VAR.Sigma.MLE(Y, X, Coef.OLS, CONST)
Beta = VAR.RMLE(Y, X, R, r, Sigma.MLE, CONST)
beta = as.vector(Beta)
(RCoef.RMLE = matrix(beta, 3, 7)                     )

        #----- MLE ︳璸竤舱ネ疭┦把计 -----#
(exog.MLE = VAR.exog.MLE(By, c(1, 3), VAR.P, CONST)  )

        #----- MLE ︳璸竤舱ネ疭┦把计 -----#
A1.Mat = matrix(1, 3, 7);       # 砞﹚êㄇ把计璶
A1.Mat[1,2] = 0; A1.Mat[1,5] = 0;
A1.Mat[3,2] = 0; A1.Mat[3,5] = 0
R1 = VAR.A2R(A1.Mat)            # 砞﹚ R
r1 = matrix(0, 21, 1)           # 砞﹚ r
Sigma.MLE = VAR.Sigma.MLE(Y, X, Coef.OLS, CONST)
Beta = VAR.RMLE(Y, X, R1, r1, Sigma.MLE, CONST)
beta = as.vector(Beta)
(RCoef1.RMLE = matrix(beta, 3, 7)                    )
(exog.RMLE = VAR.exog.RMLE(By, c(1, 3), VAR.P, CONST))

        ###### 安砞浪﹚:材 4 彻 ######
        #----- 把计︳璸:龟ㄒ 1 -----#
beta.std = VAR.OLS.Std(X, Sigma.OLS, CONST)
(Coef.OLS.Std = matrix(beta.std, 3, 7)               )
(Sigma.RFGLS= VAR.Sigma.MLE(Y, X, RCoef.RFGLS, CONST))
beta.std = VAR.RFGLS.Std(X, Sigma.RFGLS, R, CONST)
(RCoef.RFGLS.Std = matrix(beta.std, 3, 7)            )

        #----- 把计︳璸:龟ㄒ 2 -----#
Sigma1.RFGLS = VAR.Sigma.MLE(Y, X, RCoef1.RMLE, CONST)
beta.std   = VAR.RFGLS.Std(X, Sigma1.RFGLS, R1, CONST)
(RCoef1.RFGLS.Std = matrix(beta.std, 3, 7)           )

        #----- t-ratios -----#
(t.ratios = VAR.tratio(RCoef.RMLE, RCoef.RFGLS.Std)  )

        #----- Wald 浪﹚ -----#
C    = VAR.A2C(A.Mat)           # 砞﹚店礚安砞
c    = matrix(0, 4, 1)

        #----- Wald 浪﹚:龟ㄒ 1 -----#
Wald = VAR.Wald(Y, X, C, c, Sigma.OLS, CONST)
(cat("F:", Wald$F, " p-value:", 1-pf(Wald$F, 4, 354)))
C1   = VAR.A2C(A1.Mat)
c1   = matrix(0, 4, 1)

        #----- Wald 浪﹚:龟ㄒ 2 -----#
Wald1= VAR.Wald(Y, X, C1, c1, Sigma.OLS, CONST)
(cat("F:", Wald1$F," p-value:",1-pf(Wald1$F, 4, 354)))

        #----- LR 浪﹚ -----#
Sigma.RMLE = VAR.Sigma.MLE(Y, X, RCoef.RMLE, CONST)
T  = ncol(Y)
        #----- LR 浪﹚:龟ㄒ 1 -----#
(LR = VAR.LR(Sigma.MLE, Sigma.RMLE, T)               )
Coef.MLE = Coef.OLS
Log.Alt = VAR.loglike(Y,X, Coef.MLE, Sigma.MLE, CONST)
Log.Null=VAR.loglike(Y,X,RCoef.RMLE,Sigma.RMLE, CONST)
(2*(Log.Alt - Log.Null)                              )

        #----- LR 浪﹚:龟ㄒ 2 -----#
Sigma1.RMLE = VAR.Sigma.MLE(Y, X, RCoef1.RMLE, CONST)
(LR = VAR.LR(Sigma.MLE, Sigma1.RMLE, T)              )

        #----- 戈癟非玥 -----#
A0.Mat = matrix(1, 3, 7)
(SIC = VAR.IC(Sigma.MLE, A0.Mat, T)$SIC              )
(SIC = VAR.IC(Sigma.RMLE, A.Mat, T)$SIC              )
(IC = VAR.Select(By, Max.lag = 4, CONST)             )
apply(IC, 1, which.min)
(VAR.LRtestp(By, 2, CONST)                           )

        ###### 家莱ノ:材 5 彻 ######
        #----- 箇代 -----#
(forecast = VAR.forecast(By, Coef.OLS, 3, CONST)     )

        #----- Granger 狦浪﹚=Wald 浪﹚:龟ㄒ 2 -----#
Wald1= VAR.Wald(Y, X, C1, c1, Sigma.OLS, CONST)
(cat("F:", Wald1$F," p-value:",1-pf(Wald1$F, 4, 354)))

        #----- 侥阑は莱ㄧ计 -----#
IRF = VAR.IRF(impulse = 2, response = 1,
               Coef.OLS, h = 4,  Sigma.OLS, CONST)
(IRF$std                                             )
Theta = VAR.Theta(Coef.OLS, h = 2, Sigma.OLS, CONST)
(Theta$std                                           )

        #----- 侥阑は莱ㄧ计妓セ夹非畉 -----#
Psi.Std = VAR.Psi.Std(By,Coef.OLS,Sigma.OLS,h=4,CONST)
(Psi.Std[[2]]                                        )
(ddTheta.Std = VAR.ddTheta.Std(By, Coef.OLS,
               Sigma.OLS, h = 2, T = 125, CONST)     )

        #----- ┺箄猭︳衡侥阑は莱ㄧ计 -----#
VAR.Theta.bootstrap(By, VAR.P, h = 2, impulse= 2,
               response= 1, N=100, CONST)

        #----- て侥阑は莱ㄧ计 -----#
GIRF= VAR.GIRF(2, 1, Coef.OLS, h= 4, Sigma.OLS, CONST)
(GIRF$std                                            )
        #----- 箇代粇畉跑钵计だ秆 -----#
(Dec= VAR.decomp(m=1,Coef.OLS, h=5, Sigma.OLS, CONST))
VAR.decomp.GIRF(m=1, Coef.OLS, h= 5, Sigma.OLS, CONST)

        ###### SVAR ︳璸:材 7 彻 ######
        #----- A-Model 把计︳衡 -----#
Amat =diag(3)
diag(Amat) = NA;  Amat[2,1]  = NA;  Amat[3,1]  = NA
(A = VAR.example.A(By, VAR.P, Amat, CONST)           )

        #----- Blanchard-Quah 家把计︳衡 -----#
BQ = VAR.varest.BQ(By, VAR.P, CONST)
(BQ$Xi                                               )
(BQ$AB                                               )

        ###### SVAR 莱ノ:材 8 彻 ######
        #----- A-Model 侥阑は莱ㄧ计 -----#
(ddTheta.A=VAR.example.A.IRF(By,VAR.P,Amat,h=2,CONST))

        #----- Blanchard-Quah 家侥阑は莱ㄧ计 -----#
(ddTheta.BQ = VAR.svarirf.BQ(By, VAR.P, h = 2, CONST))

        #----- A-Model 箇代粇畉跑钵计だ秆 -----#
(Dec.A=VAR.example.A.decomp(1,By,VAR.P,Amat,3,CONST) )

        #----- Blanchard-Quah 家箇代粇畉跑钵计だ秆 -----#
(Dec.BQ = VAR.svardecomp.BQ(m=1,By,VAR.P,h=3,CONST)  )

        #----- A-Model 菌だ秆 -----#
Hist.Dec.A= VAR.example.A.hist(By, VAR.P, Amat, CONST)
head(Hist.Dec.A[,1:3])
head(Hist.Dec.A[,4:6])

        #----- Blanchard-Quah 家菌だ秆 -----#
Hist.BQ = VAR.svarhist.BQ(Data = By, VAR.P, CONST)
head(Hist.BQ[,1:3])

        #----- Base Project ︳璸 -----#
Hist.c0 = VAR.baseproject(By, VAR.P, CONST)
head(Hist.c0)






###### R 甅ン vars
rm(list=ls())
Path = "c:\\VAR\\"              # 砞﹚隔畖
setwd(Path)
source("VARsource.R")           # 弄 VARsource.R 郎

        ###### 弄戈  ######
file = "TWData.csv"
data = read.csv(file = file, header = TRUE)
By   = as.matrix(data[,2:4])

        ###### 把计︳璸 ######
library(vars)                   # 弄 vars 甅ン
varest = VAR(By, p = 2, type = c("const"))
summary(varest)

        ###### 把计︳璸: OLS ︳衡 ######
A.Mat  = matrix(1, 3, 7)        # 砞﹚êㄇ把计璶
A.Mat[2,3] = 0; A.Mat[2,6] = 0;
A.Mat[3,2] = 0; A.Mat[3,5] = 0;
varest.rest = restrict(varest, method = "manual",
              resmat = A.Mat)
B(varest.rest)
Acoef(varest.rest)

        ###### 箇代 ######
(forecast = predict(varest, n.ahead = 3)             )

        ###### Granger 狦 ######
(Granger = causality(varest, cause=c("y2"))          )

        ###### 侥阑は莱ㄧ计 ######
(irf = irf(varest, n.ahead = 3)                      )

        ###### 箇代粇畉跑钵计だ秆 ######
(fevd = fevd(varest, n.ahead = 10)                   )

        ###### A-Model 把计︳衡 ######
Amat =diag(3)
diag(Amat) = NA;  Amat[2,1]  = NA;  Amat[3,1]  = NA
svar = SVAR(x = varest, estmethod = "direct", Amat,
     Bmat = NULL, hessian = TRUE, method="BFGS")
summary(svar)
svar$Sigma.U

        ###### Blanchard-Quah 家把计︳衡 ######
BQ(varest)
