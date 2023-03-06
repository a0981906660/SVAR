###### VAR/SVAR �ҫ������{��
rm(list=ls())
Path = "c:\\VAR\\"              # �]�w���|
setwd(Path)
source("VARsource.R")           # Ū�� VARsource.R ��

        ###### Ū�����:�� 1 ��  ######
file = "TWData.csv"
data = read.csv(file = file, header = TRUE)
By   = as.matrix(data[,2:4])

        #----- �ҫ��]�w -----#
VAR.P = 2                       # �̤j�����ᶵ��
CONST = TRUE                    # �O�_���`�ƶ�
Y     = VAR.Y(By, VAR.P)        # �]�w Y
X     = VAR.X(By, VAR.P)        # �]�w X
ddY   = VAR.ddY(By, VAR.P)      # �]�w ddY
ddX   = VAR.ddX(By, VAR.P)      # �]�w ddX

        ###### �ѼƦ��p:�� 2 �� ######
(Coef.OLS    = VAR.OLS(Y, X, CONST)                  )
(Coef.EbyE   = VAR.EbyE(ddY, ddX, CONST)             )
(Sigma.OLS   = VAR.Sigma.OLS(Y, X, Coef.OLS, CONST)  )
(ddSigma.OLS = VAR.ddSigma.OLS(ddY, ddX, CONST)      )
(Sigma.MLE   = VAR.Sigma.MLE(Y, X, Coef.OLS, CONST)  )
(ddSigma.MLE = VAR.ddSigma.MLE(ddY, ddX, CONST)      )

        ###### ������ѼƦ��p:�� 3 �� ######
A.Mat  = matrix(1, 3, 7)        # �]�w���ǰѼƭn������
A.Mat[2,3] = 0; A.Mat[2,6] = 0;
A.Mat[3,2] = 0; A.Mat[3,5] = 0;
R = VAR.A2R(A.Mat)              # �]�w R
r = matrix(0, 21, 1)            # �]�w r

        #----- �H OLS ���p������Ѽ� -----#
Beta = VAR.ROLS(Y, X, R, r, CONST)
beta = as.vector(Beta)
(RCoef.ROLS = matrix(beta, 3, 7)                     )

        #----- �H FGLS ���p������Ѽ� -----#
Sigma.OLS = VAR.Sigma.OLS(Y, X, Coef.OLS, CONST)
Beta = VAR.RFGLS(Y, X, R, r, Sigma.OLS, CONST)
beta = as.vector(Beta)
(RCoef.RFGLS = matrix(beta, 3, 7)                    )

        #----- �H MLE ���p������Ѽ� -----#
Sigma.MLE = VAR.Sigma.MLE(Y, X, Coef.OLS, CONST)
Beta = VAR.RMLE(Y, X, R, r, Sigma.MLE, CONST)
beta = as.vector(Beta)
(RCoef.RMLE = matrix(beta, 3, 7)                     )

        #----- MLE ���p�s�ե~�ͯS�ʪ��Ѽ� -----#
(exog.MLE = VAR.exog.MLE(By, c(1, 3), VAR.P, CONST)  )

        #----- MLE ���p�s�ե~�ͯS�ʪ������Ѽ� -----#
A1.Mat = matrix(1, 3, 7);       # �]�w���ǰѼƭn������
A1.Mat[1,2] = 0; A1.Mat[1,5] = 0;
A1.Mat[3,2] = 0; A1.Mat[3,5] = 0
R1 = VAR.A2R(A1.Mat)            # �]�w R
r1 = matrix(0, 21, 1)           # �]�w r
Sigma.MLE = VAR.Sigma.MLE(Y, X, Coef.OLS, CONST)
Beta = VAR.RMLE(Y, X, R1, r1, Sigma.MLE, CONST)
beta = as.vector(Beta)
(RCoef1.RMLE = matrix(beta, 3, 7)                    )
(exog.RMLE = VAR.exog.RMLE(By, c(1, 3), VAR.P, CONST))

        ###### ���]�˩w:�� 4 �� ######
        #----- �ѼƦ��p:��� 1 -----#
beta.std = VAR.OLS.Std(X, Sigma.OLS, CONST)
(Coef.OLS.Std = matrix(beta.std, 3, 7)               )
(Sigma.RFGLS= VAR.Sigma.MLE(Y, X, RCoef.RFGLS, CONST))
beta.std = VAR.RFGLS.Std(X, Sigma.RFGLS, R, CONST)
(RCoef.RFGLS.Std = matrix(beta.std, 3, 7)            )

        #----- �ѼƦ��p:��� 2 -----#
Sigma1.RFGLS = VAR.Sigma.MLE(Y, X, RCoef1.RMLE, CONST)
beta.std   = VAR.RFGLS.Std(X, Sigma1.RFGLS, R1, CONST)
(RCoef1.RFGLS.Std = matrix(beta.std, 3, 7)           )

        #----- t-ratios -----#
(t.ratios = VAR.tratio(RCoef.RMLE, RCoef.RFGLS.Std)  )

        #----- Wald �˩w -----#
C    = VAR.A2C(A.Mat)           # �]�w��L���]
c    = matrix(0, 4, 1)

        #----- Wald �˩w:��� 1 -----#
Wald = VAR.Wald(Y, X, C, c, Sigma.OLS, CONST)
(cat("F:", Wald$F, " p-value:", 1-pf(Wald$F, 4, 354)))
C1   = VAR.A2C(A1.Mat)
c1   = matrix(0, 4, 1)

        #----- Wald �˩w:��� 2 -----#
Wald1= VAR.Wald(Y, X, C1, c1, Sigma.OLS, CONST)
(cat("F:", Wald1$F," p-value:",1-pf(Wald1$F, 4, 354)))

        #----- LR �˩w -----#
Sigma.RMLE = VAR.Sigma.MLE(Y, X, RCoef.RMLE, CONST)
T  = ncol(Y)
        #----- LR �˩w:��� 1 -----#
(LR = VAR.LR(Sigma.MLE, Sigma.RMLE, T)               )
Coef.MLE = Coef.OLS
Log.Alt = VAR.loglike(Y,X, Coef.MLE, Sigma.MLE, CONST)
Log.Null=VAR.loglike(Y,X,RCoef.RMLE,Sigma.RMLE, CONST)
(2*(Log.Alt - Log.Null)                              )

        #----- LR �˩w:��� 2 -----#
Sigma1.RMLE = VAR.Sigma.MLE(Y, X, RCoef1.RMLE, CONST)
(LR = VAR.LR(Sigma.MLE, Sigma1.RMLE, T)              )

        #----- ��T�ǫh -----#
A0.Mat = matrix(1, 3, 7)
(SIC = VAR.IC(Sigma.MLE, A0.Mat, T)$SIC              )
(SIC = VAR.IC(Sigma.RMLE, A.Mat, T)$SIC              )
(IC = VAR.Select(By, Max.lag = 4, CONST)             )
apply(IC, 1, which.min)
(VAR.LRtestp(By, 2, CONST)                           )

        ###### �ҫ�����:�� 5 �� ######
        #----- �w�� -----#
(forecast = VAR.forecast(By, Coef.OLS, 3, CONST)     )

        #----- Granger �]�G�˩w=Wald �˩w:��� 2 -----#
Wald1= VAR.Wald(Y, X, C1, c1, Sigma.OLS, CONST)
(cat("F:", Wald1$F," p-value:",1-pf(Wald1$F, 4, 354)))

        #----- ����������� -----#
IRF = VAR.IRF(impulse = 2, response = 1,
               Coef.OLS, h = 4,  Sigma.OLS, CONST)
(IRF$std                                             )
Theta = VAR.Theta(Coef.OLS, h = 2, Sigma.OLS, CONST)
(Theta$std                                           )

        #----- ����������Ƽ˥��зǮt -----#
Psi.Std = VAR.Psi.Std(By,Coef.OLS,Sigma.OLS,h=4,CONST)
(Psi.Std[[2]]                                        )
(ddTheta.Std = VAR.ddTheta.Std(By, Coef.OLS,
               Sigma.OLS, h = 2, T = 125, CONST)     )

        #----- �H�޹u�k�������������� -----#
VAR.Theta.bootstrap(By, VAR.P, h = 2, impulse= 2,
               response= 1, N=100, CONST)

        #----- �@��ƽ���������� -----#
GIRF= VAR.GIRF(2, 1, Coef.OLS, h= 4, Sigma.OLS, CONST)
(GIRF$std                                            )
        #----- �w���~�t�ܲ��Ƥ��� -----#
(Dec= VAR.decomp(m=1,Coef.OLS, h=5, Sigma.OLS, CONST))
VAR.decomp.GIRF(m=1, Coef.OLS, h= 5, Sigma.OLS, CONST)

        ###### SVAR ���p:�� 7 �� ######
        #----- A-Model �ѼƦ��� -----#
Amat =diag(3)
diag(Amat) = NA;  Amat[2,1]  = NA;  Amat[3,1]  = NA
(A = VAR.example.A(By, VAR.P, Amat, CONST)           )

        #----- Blanchard-Quah �ҫ��ѼƦ��� -----#
BQ = VAR.varest.BQ(By, VAR.P, CONST)
(BQ$Xi                                               )
(BQ$AB                                               )

        ###### SVAR ����:�� 8 �� ######
        #----- A-Model ����������� -----#
(ddTheta.A=VAR.example.A.IRF(By,VAR.P,Amat,h=2,CONST))

        #----- Blanchard-Quah �ҫ������������ -----#
(ddTheta.BQ = VAR.svarirf.BQ(By, VAR.P, h = 2, CONST))

        #----- A-Model �w���~�t�ܲ��Ƥ��� -----#
(Dec.A=VAR.example.A.decomp(1,By,VAR.P,Amat,3,CONST) )

        #----- Blanchard-Quah �ҫ��w���~�t�ܲ��Ƥ��� -----#
(Dec.BQ = VAR.svardecomp.BQ(m=1,By,VAR.P,h=3,CONST)  )

        #----- A-Model ���v���� -----#
Hist.Dec.A= VAR.example.A.hist(By, VAR.P, Amat, CONST)
head(Hist.Dec.A[,1:3])
head(Hist.Dec.A[,4:6])

        #----- Blanchard-Quah �ҫ����v���� -----#
Hist.BQ = VAR.svarhist.BQ(Data = By, VAR.P, CONST)
head(Hist.BQ[,1:3])

        #----- Base Project ���p -----#
Hist.c0 = VAR.baseproject(By, VAR.P, CONST)
head(Hist.c0)






###### R �M�� vars
rm(list=ls())
Path = "c:\\VAR\\"              # �]�w���|
setwd(Path)
source("VARsource.R")           # Ū�� VARsource.R ��

        ###### Ū�����  ######
file = "TWData.csv"
data = read.csv(file = file, header = TRUE)
By   = as.matrix(data[,2:4])

        ###### �ѼƦ��p ######
library(vars)                   # Ū�� vars �M��
varest = VAR(By, p = 2, type = c("const"))
summary(varest)

        ###### ������ѼƦ��p: OLS ���� ######
A.Mat  = matrix(1, 3, 7)        # �]�w���ǰѼƭn������
A.Mat[2,3] = 0; A.Mat[2,6] = 0;
A.Mat[3,2] = 0; A.Mat[3,5] = 0;
varest.rest = restrict(varest, method = "manual",
              resmat = A.Mat)
B(varest.rest)
Acoef(varest.rest)

        ###### �w�� ######
(forecast = predict(varest, n.ahead = 3)             )

        ###### Granger �]�G ######
(Granger = causality(varest, cause=c("y2"))          )

        ###### ����������� ######
(irf = irf(varest, n.ahead = 3)                      )

        ###### �w���~�t�ܲ��Ƥ��� ######
(fevd = fevd(varest, n.ahead = 10)                   )

        ###### A-Model �ѼƦ��� ######
Amat =diag(3)
diag(Amat) = NA;  Amat[2,1]  = NA;  Amat[3,1]  = NA
svar = SVAR(x = varest, estmethod = "direct", Amat,
     Bmat = NULL, hessian = TRUE, method="BFGS")
summary(svar)
svar$Sigma.U

        ###### Blanchard-Quah �ҫ��ѼƦ��� ######
BQ(varest)