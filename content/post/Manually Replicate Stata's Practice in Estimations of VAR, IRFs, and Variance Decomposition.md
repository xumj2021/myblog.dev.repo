---
title:       "Dig into Estimation of VAR Coefficients, IRFs, and Variance Decomposition in Stata"
subtitle:    ""
description: "Manually compute all the major outputs of VAR"
date:        2023-01-09
author:      "Mengjie Xu"
toc:         true
image:    "https://assets.bbhub.io/image/v1/resize?type=auto&url=https%3A%2F%2Fassets.bbhub.io%2Fprofessional%2Fsites%2F10%2FUK_CB_315160958_1-3_1600x1200.png"
tags:        ["Time Series", "VAR"]
categories:  ["Theory" ]
---

## Motivation

While people can always use integrated commands in Stata (e.g., `var` and `svar`) to produce abundant outputs of VAR estimation, many can not confidently interpret these results without knowing how they are theoretically defined and practically calculated. Manually replicating the outputs of the Stata's integrated commands for VAR estimation will be very helpful to resolve this issue.

In this blog, I will firstly provide the theoretical calculation formulas of reduced-form coefficients, IRFs, Structural IRFs, Orthogonalized IRFs, and Forecast Error Variance Decomposition. Then I will follow their theoretical definition to manually calculate these outputs in Stata. Finally, I will compare the manually computed results with the outputs generated from Stata's integrated commands (see in [the last blog](https://mengjiexu.com/post/common-practice-of-var-estimation-in-stata/)) and cross-check the validity of my manual computation.

By doing so, I hope this blog can provide precise insights on how the VAR outputs are produced in Stata and help the readers confidently use these results in their own research.

For readers with time constraints, all the codes used in this blog can be approched via [this link](https://mengjiexu.com/post/manually-replicate-statas-practice-in-estimations-of-var-irfs-and-variance-decomposition/#integrated-codes).

This blog is the last one of my 3-blog series about VAR model. I  show the basic logics of VAR model with the simplest 2-variable, 1-lag VAR model in [the first blog](https://mengjiexu.com/post/touch-into-var/) and show how to use `var` and `svar` commands to conveniently estimate the VAR model in Stata in [the second blog](https://mengjiexu.com/post/common-practice-of-var-estimation-in-stata/). 



## Set Benchmark

To get reliable benchmarks, I use the integrated command `svar` to generate all the major outputs of the VAR estimation with the same dataset and lag orders as what've showed in [the last blog](https://mengjiexu.com/post/common-practice-of-var-estimation-in-stata/). 

The codes are as follows. The readers can see more explanations about these commands in [the last blog](https://mengjiexu.com/post/common-practice-of-var-estimation-in-stata/). 

```
**#  generate benchmark
use varsample.dta, clear
tsset yq
matrix A1 = (1,0,0 \ .,1,0 \ .,.,1)
matrix B1 = (.,0,0 \ 0,.,0 \ 0,0,.)
svar inflation unrate ffr, lags(1/7) aeq(A1) beq(B1)
irf create forblog, step(15) set(myirf) replace
mat sigma_e_bench = e(Sigma)
mat B_bench = e(A)
mat beta_bench = e(b_var)
```



## Theoretical Definitions and Calculation Formulas

### Define the VAR system

The starting point is a structural VAR system with \\(k\\) variables and \\(p\\) lags.
$$
Bx_t=\kappa+\Sigma_{i=1}^{p}\Gamma_i x_{t-i}+\epsilon_t \tag{1}
$$
Premultiplying Equation (1) with matrix \\(B^{-1}\\), one will get the reduced-form VAR. 
$$
x_t=\nu+\Sigma_{i=1}^{p}A_i x_{t-i}+e_t  \tag{2}
$$

### Calculate reduced-form coefficients \\(A_i(i=1,2,..,p)\\)

As the OLS estimation is proved to be consistent and asymptotically efficient in reduced form (e.g., Enders, 2004), the reduced-form coefficients  \\(A_i(i=1,2,..,p)\\) are estimated directly from the OLS. 

That said, if we put \\(x_t\\) into a matrix \\(Y\\) and put \\(x_{t-i} (i=1,2,..,p)\\) in to a matrix \\(X\\), the reduced-form coefficient matrix  can \\(A_i(i=1,2,..,p)\\) be generated from the OLS coefficients
$$
\beta = (X'X)^{-1}(X'Y) \tag{3}
$$



### Calculate Impulse Response Coefficients \\(\Phi(L)\\)

Following Lütkepohl (2007, p22-23), the reduced-form VAR system defined in Equation (2) could be written as the following Vector Moving Average (VMA) representation.
$$
x_t = \mu+\Phi(L)e_t = \mu+\sum_{i=0}^{\infty}\Phi_ie_{t-i} \tag{4}
$$
The tricks are as follows. Firstly you re-write the lag terms using lag operators \\(\left(A_1 L+\cdots+A_p L^p\right) x_t\\), then you move them into the left hand side of the equation and get
$$
A(L)x_t = \nu+e_t \tag{5}
$$
where
$$
A(L)=I_K-A_1 L-\cdots-A_p L^p
$$
Let 
$$
\Phi(L)=\sum_{i=0}^{\infty} \Phi_i L^i
$$
be an operator such that 
$$
\Phi(L)A(L)=I_k
$$
where \\(k\\) is the number of variables in the VAR system.

Premultiply Equation (5) with \\(\Phi(L)\\). Call the mean factor \\(\Phi(L)\nu\\) as \\(\mu\\), we get the VMA representation of the VAR system in Equation (6).
$$
x_t = \Phi(L)\nu+\Phi(L)e_t = \mu+\sum_{i=0}^{\infty}\Phi_ie_{t-i} \tag{6}
$$
Intuitively, the coefficients of the VMA representation \\(\Phi_i (i=1,2,...,\infty)\\) captures how does a unit shock on \\(e_{t-i}\\) influences the variables of interest \\(x_t\\), which are the so-called Impulse Response Functions (IRFs) by definition. 

Lütkepohl (2007, p22-23) proves that the \\(\Phi_i\\), or so-called IRFs, can be computed recursively using
$$
\Phi_0 = I_k\\\\\\
\Phi_i = \Sigma_{j=1}^{i}\Phi_{i-j}A_j \tag{7}
$$
where \\(A_j (j=1...p)\\) are coefficients for \\(j\\)-lag variables of the reduced-form VAR system, which we have estimated through OLS.

### Calculate Orthogonalized IRFs \\(\Theta(L) \\)

Typically, there are correlations among reduced-form innovations, which makes it hard to separate the impacts of one innovation from another. In such case, to better separate the effects of one innovation from another, people usually apply Cholesky factorization of the variance-covariance matrix \\(\Sigma_e\\), which derives
$$
\Sigma_e = PP'
$$
where \\(P\\) is a lower triangular matrix.

Following  Lütkepohl (2007, p46), the VMA representation of VAR, Equation (6), can be re-written as 
$$
x_t=\mu+\sum_{i=0}^{\infty} \Phi_i P P^{-1} e_{t-i}=\mu+\sum_{i=0}^{\infty} \Theta_i w_{t-i} \tag{8}
$$
where \\(\Theta_i=\Phi_i P\\) and \\(w_t=P^{-1} e_t\\). The following equation proves that \\(w_t\\) is white noise with covariance matrix of identity matrix \\(I_k\\), which implies the innovations \\(w_t\\) have uncorrelated components. Thus,  \\(w_t\\)  are also called orthogonal innovations.
$$
\Sigma_w=P^{-1} \Sigma_e\left(P^{-1}\right)^{\prime}=I_K \tag{9}
$$
Correspondingly, the new IRF coefficients \\(\Theta_i=\Phi_i P\\) which functions on the orthogonal innovations \\(w_t\\) are called orthogonalized IRFs. In other words, the orthogonalized IRFs are given by the following Equation.
$$
\Theta_i=\Phi_i P \tag{10}
$$
where \\(\Phi_i(i=1,2,...,\infty)\\) are the IRFs and  \\(P\\)  is the Cholesky decomposition of the variance-covariance matrix  \\(\Sigma_e\\)  such that \\(\Sigma_e = PP'\\)

Clearly, the calculation of  \\(P\\)  needs the covariance matrix of residuals  \\(\Sigma_e\\). 

Recall that we've put \\(x_t\\) into a matrix  \\(Y_t\\)  and put \\(x_{t-i} (i=1,2,..,p)\\) in to a matrix  \\(X\\) , the reduced-form coefficient matrix \\(\beta\\) carries the OLS coefficients, which we have estimated in Equation (3). Then the residuals of VAR estimation  \\(e\\)  are by definition
$$
e = Y-X\beta \tag{11}
$$
The variance-covariance matrix of the residuals \\(\Sigma_e\\) can be calculated with
$$
\Sigma_e =E[(e-\bar{e})(e-\bar{e})']\tag{12}
$$



### Calculate (Orthogonalized) Structural IRFs  \\(\Psi(L)\\) 

The structural IRFs by definition captures the impacts of one-unit structural shock \\(\epsilon_t\\) on the variables of interest \\(x_t\\). Recall that \\(e_t = B^{-1}\epsilon_t\\), one can conveniently compute the structural IRFs by plugging it into the Equation (6).
$$
x_t =\mu+\Phi(L)e_t =\mu+\Phi(L)B^{-1}\epsilon_t=\mu+\Lambda(L)\epsilon_t \tag{13}
$$
One can intuitively infer from the Equation (13) that the structural IRFs (SIRFs) should be the IRFs \\(\Phi_i\\) postmultiplied by \\(B^{-1}\\) as in Equation (9).
$$
\Lambda_i=\Phi_iB^{-1} 
$$

Clearly, the matrix \\(B\\) is the prerequisite for estimating Structural IRFs \\(\Lambda(L)\\). 

Given that Stata's `var` command by default assumes \\(B\\) is a \\(k\times k\\) lower triangular matrix with ones in the diagonal, we could figure out the unresovled elements \\(B_{ij}\\) from the relations of the reduced-form residuals. 
$$
B=\left(\begin{array}{ccc}
1 & 0 & 0&...&0 \\\\\\
B_{21} & 1 & 0&...&0 \\\\\\
B_{31} & B_{32} & 1&...&0\\\\\\
...&...&...&...&...&\\\\\\
B_{k1}&B_{k2}&B_{k3}&...&1
\end{array}\right)
$$
In particular, we could start from \\(\epsilon_t = Be_t\\), which implies
$$
\\left(\begin{array}{ccc}\epsilon_{1t}\\\\\\
\epsilon_{2t}\\\\\\
\epsilon_{3t}\\\\\\
...\\\\\\
\epsilon_{kt} \end{array}\right)=\left(\begin{array}{ccc}
1 & 0 & 0&...&0 \\\\\\
B_{21} & 1 & 0&...&0 \\\\\\
B_{31} & B_{32} & 1&...&0\\\\\\
...&...&...&...&...&\\\\\\
B_{k1}&B_{k2}&B_{k3}&...&1
\end{array}\right)
\\left(\begin{array}{ccc}e_{1t}\\\\\\
e_{2t}\\\\\\
e_{3t}\\\\\\
...\\\\\\
e_{kt} \end{array}\right)
$$
Writing in a loose form 
$$
\begin{aligned}e_{1t} &= \epsilon_{1t}\\\\\\
e_{2t} &= \epsilon_{2t}- B_{21}e_{1t}\\\\\\
e_{3t} &= \epsilon_{3t}- B_{31}e_{1t}-B_{32}e_{2t}\\\\\\
...\\\\\\
e_{kt}& = \epsilon_{kt}-B_{k1}e_{1t}-B_{k2}e_{2t}-...-B_{kk-1}e_{k-1t}
\end{aligned}
$$
Note that the \\(\epsilon_{it}\\) are real numbers in the above regressions. That said by running the above \\(k\\) regressions on the reduced-form residuals \\(e_{it}(i=1,...,k)\\), one can obtain all the unresolved elements in the matrix \\(B\\). For example, by regressing \\(e_{kt}\\) on \\(e_{1t}\\) to \\(e_{k-1t}\\), one can get the coefficients \\(B_{k1}\\) to \\(B_{kk-1}\\), which are components of the last row in the matrix \\(B\\).

While people usually assume that the structural shocks \\(\epsilon_t\\)  are orthogonal unit impulse, it is not always the case in the dataset. Most of the time, while there are few contemporaneous correlations among different structural shocks, the structural shocks do have non-unit variance. In such case, people typically standardize structural IRFs into unit shocks by introducing a factorization of the covariance matrix of the structural shocks \\(\Sigma_\epsilon\\) , just like what we did to get the Orthogonalized IRFs in the last subsection.

The covariance matrix of the structural shocks \\(\Sigma_\epsilon\\) can be computed based on \\(e_t = B^{-1}\epsilon_t\\) .
$$
\Sigma_\epsilon = E(\epsilon\epsilon')=E(Be_tet'B')=B\Sigma_eB'
$$
We decompose \\(\Sigma_\epsilon\\) such that
$$
\Sigma_\epsilon = P_1P_1'
$$
The orthogonalized structural IRFs would be 
$$
\Psi_i=\Lambda_i P_1=\Phi_iB^{-1}P_1\tag{14}
$$


### Calculate Forecast Error Variance Decomposition (FEVD)

Following  Lütkepohl (2007, p63-64), the error in the optimal \\(h\\) -step forecast can be derived from the VMA representation in Equation (6).
$$
\begin{aligned}
x_{t+h}-x_t(h) & =\sum_{i=0}^{h-1} \Phi_i e_{t+h-i}\\\\\\
& =\sum_{i=0}^{h-1} \Phi_i P P^{-1} e_{t+h-i} \\\\\\
& =\sum_{i=0}^{h-1} \Theta_i w_{t+h-i} .
\end{aligned} \tag{15}
$$
As the \\(w_t\\) is white noise with identity matrix \\(I_k\\) as covariance matrix, the variance of each factor in \\(w_t\\) is 1. Denote the \\(js\\)-th element of \\(i\\)-step orthogonalized IRFs \\(\Theta_i\\)as \\(\theta_{js,i}\\) , the  \\(h\\)-step forecast Mean Squared Error (MSE) of variable \\(j\\) can be written as the sum of the squared orthogonalized IRFs.
$$
\operatorname{MSE}\left[x_{j, t}(h)\right]=\sum_{i=0}^{h-1} \sum_{s=1}^k \theta_{j s, i}^2 \tag{16}
$$
where \\(\theta_{js,i}\\) is the orthogonalized IRF from innovation from variable \\(s\\) to variable \\(j\\) with \\(i\\)-step lag(s). \\(k\\) is the variable numbers in the VAR system.

The \\(h\\)-step variance contribution of innovations from variable \\(s\\) to variable \\(j\\) is by definition
$$
\Omega_{js,h} = \frac{\sum_{i=0}^{h-1} \theta_{j s, i}^2}{\sum_{i=0}^{h-1} \sum_{s=1}^k \theta_{j s, i}^2} \tag{17}
$$
### Summary of formulas

For a structural VAR system with \\(k\\) variables and \\(p\\) lags.

- The reduced-form coefficients \\(A_i(i=1,2,..,p)\\) are the coefficients of the OLS estimation for the reduced-form VAR
- The Impulse Response Coefficients \\(\Phi(L)\\) can be estimated with Equation (7). The prerequisite is the  reduced-form coefficients \\(A_i(i=1,2,..,p)\\)
- The Orthogonalized IRFs \\(\Theta(L)\\) can be obtained by postmultipling IRF matrix \\(\Phi(L)\\) with \\(P\\), where \\(\Sigma_e = PP'\\). The prerequisites are the IRF \\(\Phi(L)\\) and the variance-covariance matrix of residuals \\(\Sigma_e\\)
- The orthogonalized Structural IRFs \\(\Psi(L)\\) can be obtained by postmultipling IRF matrix \\(\Phi(L)\\) with \\(B^{-1}P_1\\). The prerequisite are the IRF \\(\Phi(L)\\), contemporaneous effect matrix \\(B\\) , and covariance matrix of structural shocks \\(\Sigma_\epsilon\\) such that \\(\Sigma_\epsilon=P_1P_1'\\)
- The Forecast Error Variance Decomposition \\(\Omega_{js,h}\\) can be obtained by calculating the sum of the squared orthogonalized IRFs of impulse \\(s\\) on equation \\(j\\) from the 1st step to \\(h-1\\) step standardized by the Mean Squared Forecast Error, which could also be calculated from the orthogonalized IRFs  \\(\Theta(L)\\). The prerequisite is only the orthogonalized IRFs \\(\Theta(L)\\)


## Manually Compute the VAR outputs in Stata

### Import Data and define global variables 

To keep consistent with the benchmark, where we produce all these outputs using integrated commands `var` in the last blog, I will use the same sample dataset and choose the same number of lag orders as 7.

That said, the VAR system we will replicate has 3 variables and 7 lags. The model is as follows.
$$
\\left[\begin{array}{c}
inflation_{t}\\\\\\
unrate_{t}\\\\\\
ffr_{t}
\end{array}\right]=A_0+A_1
\left[\begin{array}{c}
inflation_{t-1}\\\\\\
unrate_{t-1}\\\\\\
ffr_{t-1}
\end{array}\right]+\cdots+A_7
\left[\begin{array}{c}
inflation_{t-7}\\\\\\
unrate_{t-7}\\\\\\
ffr_{t-7}
\end{array}\right]+e_t
$$
Please see codes for this step below.

```
* prepare data
sysuse varsample.dta, clear
tsset yq

* define global variables
global names "inflation unrate ffr"
global lagorder 7
global numnames 3
```



### Compute reduced-form coefficients \\(A_i(i=1,2,..,p)\\) 

To compute reduced-form coefficients \\(A_i(i=1,2,..,p)\\), we put \\(x_t\\) into a matrix \\(Y\\) and put \\(x_{t-i} (i=1,2,..,p)\\) in to a matrix \\(X\\), the reduced-form coefficient matrix \\(A\\) can be generated from the OLS coefficients 
$$
\beta = (X'X)^{-1}(X'Y)
$$
The codes are as follows. I firstly generate the 1 to \\(p\\) lag of each variable in the VAR system. And then put them all together into a matrix \\(X\\), put the contemporaneous variables into a matrix \\(Y\\). The coefficients of OLS estimation are stored in matrix `beta`, which is a \\(22\times3\\) matrix, where 22 = 3\\(\times\\)7+1.

```
* generate lag variables 
foreach var in $names{
	forvalues j = 1/$lagorder{
		cap g l`j'`var' = l`j'."`var'"
	}
}

* put x and y of the reduced-form VAR into the matrix
mkmat $names, matrix(Y)
mat Y = Y[$lagorder+1..rowsof(y), 1..colsof(Y)]
mkmat l*inflation l*unrate l*ffr, matrix(X) nomiss
mat X = (X, J(rowsof(X), 1, 1))

* estimate the OLS coefficients of the reduced-form VAR
mat beta = inv(X'*X)*(X'*Y)
```

The manually computed reduce-form coefficient matrix `beta` is as follows.

```
. mat list beta

beta[22,3]
              inflation      unrate         ffr
l1inflation   1.1624496  -1.2311559  -4.7074491
l2inflation  -.38442299   3.4434416    14.62629
l3inflation   .33067581  -.10661715  -13.797021
l4inflation  -.19803137   1.2593467   18.506895
l5inflation   .25709458  -2.6615204  -8.1949518
l6inflation  -.08613706   .80816382   14.682903
l7inflation  -.07969876  -1.4801693  -22.071136
   l1unrate  -.00704289   1.3298207  -2.0448181
   l2unrate   .00719199   .00238958   1.5423312
   l3unrate   .00217432  -.34914135   .45998626
   l4unrate   .00246865  -.18703379   .28127488
   l5unrate  -.00964455   .26099715   .38580282
   l6unrate   .00855645  -.08923544  -1.1106103
   l7unrate  -.00384815   -.0158381   .44636919
      l1ffr    .0000775    .0391868   .28705469
      l2ffr   .00092119    .0133781   .17792134
      l3ffr   .00073382   -.0020393   .44964119
      l4ffr   .00051456  -.04211502    .2517726
      l5ffr  -.00075606  -.01041068   .05375644
      l6ffr  -.00027879  -.00274284  -.16801173
      l7ffr  -.00085278   .01797453  -.22845819
         c1   .00707448   .12277881   1.0777927
```

As we are estimating a VAR system with 3 variables and 7 lags, we need to derive coefficient matrix \\(A_i(i=1,2,..,p)\\) from \\(\beta\\). Each of the \\(A_i\\) is a \\(3\times 3\\) matrix. The \\(js\\)-th element of matrix \\(A_i\\) denotes the IRFs of impulse \\(s\\) on equation \\(j\\) with \\(i\\) lags.

```
* reshape beta to generate reduced-form VAR coefficient matrix a1-ap
forvalues i=1/$lagorder{
	mat A`i' = (beta["l`i'inflation", 1..3]\beta["l`i'unrate", 1..3]\beta["l`i'ffr", 1..3])'
}
```

I list the three-lag coefficient matrix \\(A_3\\) as an example. One can easily find the consistency with the coefficient matrix `beta`.

```
. mat list A3

A3[3,3]
           l3inflation     l3unrate        l3ffr
inflation    .33067581    .00217432    .00073382
   unrate   -.10661715   -.34914135    -.0020393
      ffr   -13.797021    .45998626    .44964119
```



### Compute and decompose the covariance matrix \\(\Sigma_e\\) and \\(\Sigma_\epsilon\\)

The reduced-form residuals \\(e\\) are given by
$$
e = Y-X\beta
$$
It's covariance matrix is 
$$
\Sigma_e =\frac{(e-\bar{e})(e-\bar{e})'}{n-p} 
$$
where \\(n\\) is the number of observations in the dataset and \\(p\\) is the number of lag order specified.

The covariance matrix of structural shock \\(\epsilon_t\\) is 
$$
\Sigma_\epsilon = B\Sigma_eB'
$$
I decompose the covariance matrix \\(\Sigma_e\\) and \\(\Sigma_\epsilon\\) such that
$$
\Sigma_e=PP', \Sigma_\epsilon=P_1P_1'
$$
The codes are as follows. Note that I save the reduced-form residuals of `inflation`, `unrate`, and `ffr` equations as \\(e_1\\), \\(e_2\\), and \\(e_3\\) respectively in this step. 

```
* compute sigma_e
mat e=Y-X*beta
mat e=J($lagorder,$numnames,.) \ e
svmat e
mat accum sigma_e = e1 e2 e3, deviations noconstant
mat sigma_e = sigma_e/(_N-$lagorder)
mat list sigma_e

* decompose sigma_e
mat P = cholesky(sigma_e)
mat list P

* compute and decompose sigma_epsilon
mat sigma_epsilon = B*sigma_e*B'
mat P1 = cholesky(sigma_epsilon)
mat list P1
```

The decomposition results of \\(\Sigma_e\\) and \\(\Sigma_\epsilon\\) are as follows. As expected, both of them are lower triangular matrix.

```
. mat list P

P[3,3]
            e1          e2          e3
e1   .00838539           0           0
e2  -.02380259   .26616909           0
e3   .29854297   -.4021685   1.4708232

. mat list P1

symmetric P1[3,3]
            r1          r2          r3
r1   .00838539
r2   3.232e-18   .26616909
r3  -5.172e-17   1.518e-16   1.4708232
```



### Compute the contemporaneous matrix \\(B\\)

Note that \\(e_t = B^{-1}\epsilon_t\\), that means we can estimate the unknown factors \\(B_{21}\\), \\(B_{31}\\), and \\(B_{32}\\) from the relationships of residuals of the reduced-form.
$$
\left(\begin{array}{ccc}\epsilon_{1,t}\\\\\\
\epsilon_{2,t}\\\\\\
\epsilon_{3,t} \end{array}\right) =\left(\begin{array}{ccc}
1 & 0 & 0 \\\\\\
B_{21} & 1 & 0 \\\\\\
B_{31} & B_{32} & 1
\end{array}\right)
\left(\begin{array}{ccc}e_{1,t}\\\\\\
e_{2,t}\\\\\\
e_{3,t} \end{array}\right)
$$

To be exact, the above matrix implies
$$
\begin{array}{c}
e_{2,t} = \epsilon_{2,t}-B_{21}\times e_{1,t}\\\\\\
e_{3,t} = \epsilon_{3,t} - B_{31}\times e_{1,t} - B_{32}\times e_{2,t} \end{array}
$$
That is to say, we can estimate \\(B_{21}\\) by regressing the reduced-form residual \\(e_{2,t}\\) on \\(e_{1,t}\\), and we estimate \\(B_{31}\\) and \\(B_{32}\\) by regressing the reduced-form residual \\(e_{3,t}\\) on \\(e_{1,t}\\) and \\(e_{2,t}\\).

```
* estimate inverse of B
qui reg e2 e1
global B21 = -e(b)[1,1]
qui reg e3 e1 e2
global B31 = -e(b)[1,1]
global B32 = -e(b)[1,2]
* construct matrix B
mat B = (1,0,0 \ $B21,1,0 \ $B31,$B32,1)
```

The manually constructed matrix \\(B\\) is as follows.

```
. mat list B

B[3,3]
            c1          c2          c3
r1           1           0           0
r2   2.8385778           1           0
r3  -31.313795   1.5109512           1
```



### Compute IRFs \\(\Phi(L)\\), Orthogonalized IRFs \\(\Theta(L)\\) , and Structural IRFs \\(\Psi(L)\\) 

I follow formula from Lütkepohl (2007) to calculate the IRFs.
$$
\Phi_0 = I_k\\\\\\
\Phi_i = \Sigma_{j=1}^{i}\Phi_{i-j}A_j
$$
I post-multiply IRF \\(\Phi_i\\) with \\(P\\) to get orthogonalized IRFs \\(\Theta_i\\).

I post-multiply IRF \\(\Phi_i\\) with \\(B^{-1}P_1\\) to get (orthogonalized) structural IRFs \\(\Psi_i\\).

The number of forecast steps is set to be 15 in this blog.

```
* estimate IRFs, OIRFs, and SIRFs
mat irf0 = I($numnames)
mat sirf0 = irf0*inv(B)*P1
mat oirf0 = irf0*P
forvalues i=1/15{
	mat irf`i' = J($numnames,$numnames,0)
	forvalues j = 1/$lagorder{
	if `i' >= `j'{
	local temp = `i'-`j'
	mat temp2 = irf`temp'*A`j'
	mat irf`i' = irf`i'+ temp2
}
}
	mat sirf`i' = irf`i'*inv(B)*P1
	mat oirf`i' = irf`i'*P
}
```

To this stage, we've got the IRF, OIRF, and SIRF matrix for each forward-look step. For ease of observing, I collect the outputs of all steps together and write them into a new dataset named `fullirfs.dta`.

```
* collect irf matrix into dataset
cap program drop reshapemat 
cap program define reshapemat
cap mat drop c`1'
forvalues i=0/15{
	mat colnames `1'`i' = $names
	mat rownames `1'`i' = $names
	mat temp1=vec(`1'`i')
	mat c`1' = nullmat(c`1') \ temp1
}
mat colnames c`1' = "`1'"
end

* write identifiers
local irfnames "irf sirf oirf"
cap mat drop fullirfs
foreach name in `irfnames'{
	reshapemat  `name'
	mat fullirfs = (nullmat(fullirfs), c`name')
}
mat list fullirfs

* save matrix as dataset
clear
svmat fullirfs, names(col)
g rownames = ""
local rownames : rowfullnames coirf
local c : word count `rownames'
forvalues i = 1/`c' {
    qui replace rownames = "`:word `i' of `rownames''" in `i'
}

* get impulse and response
split rownames, p(":")
rename rownames2 response
rename rownames1 impulse
drop rownames

* tag forward-looking steps
g step = floor((_n-1)/9)

save fullirfs, replace
```

Please see below the first 18 rows of this dataset `fullirfs.dta`, which contains all the manually collected IRFs.

```
. list impulse response step *irf in 1/18

     +------------------------------------------------------------------+
     |   impulse    response   step         irf        sirf        oirf |
     |------------------------------------------------------------------|
  1. | inflation   inflation      0           1    .0083854    .0083854 |
  2. | inflation      unrate      0           0   -.0238026   -.0238026 |
  3. | inflation         ffr      0           0     .298543     .298543 |
  4. |    unrate   inflation      0           0           0           0 |
  5. |    unrate      unrate      0           1    .2661691    .2661691 |
     |------------------------------------------------------------------|
  6. |    unrate         ffr      0           0   -.4021685   -.4021685 |
  7. |       ffr   inflation      0           0           0           0 |
  8. |       ffr      unrate      0           0           0           0 |
  9. |       ffr         ffr      0           1    1.470823    1.470823 |
 10. | inflation   inflation      1     1.16245    .0099384    .0099384 |
     |------------------------------------------------------------------|
 11. | inflation      unrate      1   -1.231156    -.030278    -.030278 |
 12. | inflation         ffr      1   -4.707449    .0948963    .0948963 |
 13. |    unrate   inflation      1   -.0070429   -.0019058   -.0019058 |
 14. |    unrate      unrate      1    1.329821    .3381975    .3381975 |
 15. |    unrate         ffr      1   -2.044818   -.6597117   -.6597117 |
     |------------------------------------------------------------------|
 16. |       ffr   inflation      1    .0000775     .000114     .000114 |
 17. |       ffr      unrate      1    .0391868    .0576369    .0576369 |
 18. |       ffr         ffr      1    .2870547    .4222067    .4222067 |
     +------------------------------------------------------------------+
```



### Compute the Forecast Error Variance Decomposition (FEVD)

Based on the collected IRF dataset `fullirfs.dta`, I follow the following formula to decompose the mean squared forecast errors , where \\(\theta_{js,i}\\) is the orthogonalized IRF from impulse of variable \\(s\\) to variable \\(j\\) with \\(i\\)-step lag(s). The results of each step's Mean Squared Error (MSE) and variance decomposition are saved into a new dataset `fevds.dta`.
$$
\Omega_{js,h} = \frac{\sum_{i=0}^{h-1} \theta_{j s, i}^2}{\sum_{i=0}^{h-1} \sum_{s=1}^k \theta_{j s, i}^2}
$$

```
* import oirfs
use fullirfs, replace

* calculate the sqaured irfs
g sqoirf = oirf^2

* calculate the MSE and variables' variance contribution for each step
sort step response impulse
by step response: egen temp = sum(sqoirf)
sort response impulse step
by response impulse: g mse = sum(temp)
by response impulse: g cvarcontri = sum(sqoirf)

* calculate fevd
g fevd_manual = cvarcontri/mse
keep step response impulse mse fevd_manual

* adjust forward-looking steps
replace step = step +1 

save fevds, replace
```

Please see below the first 18 rows of the dataset `fevds.dta`, which contains the MSE and variance decomposition results.

```
. list impulse response step fevd_manual mse in 1/18

     +----------------------------------------------------+
     |   impulse    response   step   fevd_m~l        mse |
     |----------------------------------------------------|
  1. | inflation   inflation      1          1   .0000703 |
  2. |    unrate   inflation      1          0   .0000703 |
  3. |       ffr   inflation      1          0   .0000703 |
  4. | inflation      unrate      1   .0079337   .0714126 |
  5. |    unrate      unrate      1   .9920663   .0714126 |
     |----------------------------------------------------|
  6. |       ffr      unrate      1          0   .0714126 |
  7. | inflation         ffr      1   .0369184   2.414188 |
  8. |    unrate         ffr      1   .0669954   2.414188 |
  9. |       ffr         ffr      1   .8960862   2.414188 |
 10. | inflation   inflation      2   .9788982   .0001727 |
     |----------------------------------------------------|
 11. |    unrate   inflation      2   .0210266   .0001727 |
 12. |       ffr   inflation      2   .0000752   .0001727 |
 13. | inflation      unrate      2   .0078057   .1900288 |
 14. |    unrate      unrate      2   .9747127   .1900288 |
 15. |       ffr      unrate      2   .0174816   .1900288 |
     |----------------------------------------------------|
 16. | inflation         ffr      2    .032316   3.036672 |
 17. |    unrate         ffr      2   .1965833   3.036672 |
 18. |       ffr         ffr      2   .7711006   3.036672 |
     +----------------------------------------------------+
```



## Compare Manually Computed Results with Benchmark

To check the validity of my manually computations, I list these computations and the benchmark together to see whether they are consistent.

### Check reduced-form coefficients

I firstly reshape the coefficient matrix of the benchmark to make sure it has the same shape as my manually computed coefficient matrix `beta`.

```
* reshape 
mata
	beta_bench = st_matrix("beta_bench")
	beta_bench = rowshape(beta_bench, $numnames)'
	st_matrix("beta_bench", beta_bench)
end

mat betas = (beta, beta_bench)
mat list betas
```

Then I put them together into a matrix called `betas`, where the first three columns are manually computed coefficients and the last three columns are coefficients produced by `svar`. The `betas` matrix is as follows. Clearly, they are exactly the same.

```
. mat list betas

betas[22,6]
              inflation      unrate         ffr          c1          c2          c3
l1inflation   1.1624496  -1.2311559  -4.7074491   1.1624496  -1.2311559  -4.7074491
l2inflation  -.38442299   3.4434416    14.62629  -.38442299   3.4434415    14.62629
l3inflation   .33067581  -.10661715  -13.797021   .33067581  -.10661715  -13.797021
l4inflation  -.19803137   1.2593467   18.506895  -.19803137   1.2593467   18.506895
l5inflation   .25709458  -2.6615204  -8.1949518   .25709458  -2.6615204  -8.1949518
l6inflation  -.08613706   .80816382   14.682903  -.08613706   .80816382   14.682903
l7inflation  -.07969876  -1.4801693  -22.071136  -.07969876  -1.4801693  -22.071136
   l1unrate  -.00704289   1.3298207  -2.0448181  -.00704289   1.3298207  -2.0448181
   l2unrate   .00719199   .00238958   1.5423312   .00719199   .00238958   1.5423312
   l3unrate   .00217432  -.34914135   .45998626   .00217432  -.34914135   .45998626
   l4unrate   .00246865  -.18703379   .28127488   .00246865  -.18703379   .28127488
   l5unrate  -.00964455   .26099715   .38580282  -.00964455   .26099715   .38580282
   l6unrate   .00855645  -.08923544  -1.1106103   .00855645  -.08923544  -1.1106103
   l7unrate  -.00384815   -.0158381   .44636919  -.00384815   -.0158381   .44636919
      l1ffr    .0000775    .0391868   .28705469    .0000775    .0391868   .28705469
      l2ffr   .00092119    .0133781   .17792134   .00092119    .0133781   .17792134
      l3ffr   .00073382   -.0020393   .44964119   .00073382   -.0020393   .44964119
      l4ffr   .00051456  -.04211502    .2517726   .00051456  -.04211502    .2517726
      l5ffr  -.00075606  -.01041068   .05375644  -.00075606  -.01041068   .05375644
      l6ffr  -.00027879  -.00274284  -.16801173  -.00027879  -.00274284  -.16801173
      l7ffr  -.00085278   .01797453  -.22845819  -.00085278   .01797453  -.22845819
         c1   .00707448   .12277881   1.0777927   .00707448   .12277881   1.0777927
```



### Check parameter matrix \\(\Sigma_e\\), \\(\Sigma_\epsilon\\) and \\(B\\)

The codes and results are as follows. Clearly, they are exactly the same.

```
. * check variance-covariance matrix
. mat list sigma_e
symmetric sigma_e[3,3]
            e1          e2          e3
e1   .00007031
e2  -.00019959   .07141255
e3    .0025034  -.11415092   2.4141883

. mat list sigma_e_bench
symmetric sigma_e_bench[3,3]
            inflation      unrate         ffr
inflation   .00007031
   unrate  -.00019959   .07141255
      ffr    .0025034  -.11415092   2.4141882

. * check matrix B
. mat list B
B[3,3]
            c1          c2          c3
r1           1           0           0
r2   2.8385778           1           0
r3  -31.313795   1.5109512           1
. mat list B_bench
B_bench[3,3]
            inflation      unrate         ffr
inflation           1           0           0
   unrate   2.8385778           1           0
      ffr  -31.313794   1.5109512           1
```



### Check IRF, OIRF, and SIRF

I merge my manually computed IRF dataset `fullirfs.dta` with the output dataset `myirf.irf` produced by `svar` command, with the joining keys of impulse name, response name, and forward-looking step.

```
* check irfs
use myirf.irf, replace
rename *irf b*irf
joinby impulse response step using fullirfs
order impulse response step birf irf boirf oirf bsirf sirf
format *irf %6.0g
list impulse response step birf irf boirf oirf bsirf sirf in 1/20
```

I add `b` to the name of all the IRFs in the benchmark dataset and list the first 18 rows of the comparison as follows. Clearly, they are exactly the same.

```
. list impulse response step birf irf boirf oirf bsirf sirf in 1/18

     +------------------------------------------------------------------------------------------+
     |   impulse    response   step      birf       irf     boirf      oirf     bsirf      sirf |
     |------------------------------------------------------------------------------------------|
  1. | inflation   inflation      0         1         1     .0084     .0084     .0084     .0084 |
  2. |    unrate   inflation      0         0         0         0         0         0         0 |
  3. |       ffr   inflation      0         0         0         0         0         0         0 |
  4. | inflation      unrate      0         0         0    -.0238    -.0238    -.0238    -.0238 |
  5. |    unrate      unrate      0         1         1     .2662     .2662     .2662     .2662 |
     |------------------------------------------------------------------------------------------|
  6. |       ffr      unrate      0         0         0         0         0         0         0 |
  7. | inflation         ffr      0         0         0     .2985     .2985     .2985     .2985 |
  8. |    unrate         ffr      0         0         0    -.4022    -.4022    -.4022    -.4022 |
  9. |       ffr         ffr      0         1         1     1.471     1.471     1.471     1.471 |
 10. | inflation   inflation      1     1.162     1.162     .0099     .0099     .0099     .0099 |
     |------------------------------------------------------------------------------------------|
 11. |    unrate   inflation      1     -.007     -.007    -.0019    -.0019    -.0019    -.0019 |
 12. |       ffr   inflation      1   7.7e-05   7.7e-05   1.1e-04   1.1e-04   1.1e-04   1.1e-04 |
 13. | inflation      unrate      1    -1.231    -1.231    -.0303    -.0303    -.0303    -.0303 |
 14. |    unrate      unrate      1      1.33      1.33     .3382     .3382     .3382     .3382 |
 15. |       ffr      unrate      1     .0392     .0392     .0576     .0576     .0576     .0576 |
     |------------------------------------------------------------------------------------------|
 16. | inflation         ffr      1    -4.707    -4.707     .0949     .0949     .0949     .0949 |
 17. |    unrate         ffr      1    -2.045    -2.045    -.6597    -.6597    -.6597    -.6597 |
 18. |       ffr         ffr      1     .2871     .2871     .4222     .4222     .4222     .4222 |
     +------------------------------------------------------------------------------------------+

```



### Check MSE and FEVD

I merge my manually computed variance decomposition dataset `fevds.dta` with the output dataset `myirf.irf` produced by `svar` command, with the joining keys of impulse name, response name, and forward-looking step. Note that the Mean Squared Error stored in the `myirf.irf` dataset is actually the square root of MSE, I used its square as the benchmark for my manually computed MSE.

```
* check fevd
use myirf.irf, replace
rename fevd bfevd
g bmse = mse^2
rename mse rmse
joinby impulse response step using fevds
order impulse response step bfevd fevd_manual bmse mse
list impulse response step bfevd fevd_manual bmse mse in 1/18
```

I add `b` to the name of MSE and FEVD in the benchmark dataset and list the first 18 rows of the comparison as follows. Clearly, they are exactly the same.

```
. list impulse response step bfevd fevd_manual bmse mse in 1/18

     +---------------------------------------------------------------------------+
     |   impulse    response   step       bfevd   fevd_m~l       bmse        mse |
     |---------------------------------------------------------------------------|
  1. | inflation   inflation      1           1          1   .0000703   .0000703 |
  2. |    unrate   inflation      1           0          0   .0000703   .0000703 |
  3. |       ffr   inflation      1           0          0   .0000703   .0000703 |
  4. | inflation      unrate      1   .00793366   .0079337   .0714125   .0714126 |
  5. |    unrate      unrate      1   .99206634   .9920663   .0714125   .0714126 |
     |---------------------------------------------------------------------------|
  6. |       ffr      unrate      1           0          0   .0714125   .0714126 |
  7. | inflation         ffr      1   .03691837   .0369184   2.414188   2.414188 |
  8. |    unrate         ffr      1    .0669954   .0669954   2.414188   2.414188 |
  9. |       ffr         ffr      1   .89608622   .8960862   2.414188   2.414188 |
 10. | inflation   inflation      2   .97889819   .9788982   .0001727   .0001727 |
     |---------------------------------------------------------------------------|
 11. |    unrate   inflation      2   .02102659   .0210266   .0001727   .0001727 |
 12. |       ffr   inflation      2   .00007522   .0000752   .0001727   .0001727 |
 13. | inflation      unrate      2   .00780575   .0078057   .1900288   .1900288 |
 14. |    unrate      unrate      2   .97471266   .9747127   .1900288   .1900288 |
 15. |       ffr      unrate      2   .01748159   .0174816   .1900288   .1900288 |
     |---------------------------------------------------------------------------|
 16. | inflation         ffr      2   .03231605    .032316   3.036672   3.036672 |
 17. |    unrate         ffr      2   .19658335   .1965833   3.036672   3.036672 |
 18. |       ffr         ffr      2   .77110061   .7711006   3.036672   3.036672 |
     +---------------------------------------------------------------------------+
```



## Integrated Codes

```
**# Manually compute VAR
* prepare data
sysuse varsample.dta, clear

* define global variables
global names "inflation unrate ffr"
global lagorder 7
global numnames 3

* generate lag variables 
foreach var in $names{
	forvalues j = 1/$lagorder{
		cap g l`j'`var' = l`j'."`var'"
	}
}

* put x and y of the reduced-form VAR into the matrix
mkmat $names, matrix(Y)
mat Y = Y[$lagorder+1..rowsof(y), 1..colsof(Y)]
mkmat l*inflation l*unrate l*ffr, matrix(X) nomiss
mat X = (X, J(rowsof(X), 1, 1))

* estimate the OLS coefficients of the reduced-form VAR
mat beta = inv(X'*X)*(X'*Y)
mat list beta

* reshape generate reduced-form VAR coefficient matrix a1-ap
forvalues i=1/$lagorder{
	mat A`i' = (beta["l`i'inflation", 1..3]\beta["l`i'unrate", 1..3]\beta["l`i'ffr", 1..3])'
	mat list A`i'
}

* compute sigma_e
mat e=Y-X*beta
mat e=J($lagorder,$numnames,.) \ e
svmat e
mat accum sigma_e = e1 e2 e3, deviations noconstant
mat sigma_e = sigma_e/(_N-$lagorder)
mat list sigma_e

* decompose sigma_e
mat P = cholesky(sigma_e)
mat list P

* compute and decompose sigma_epsilon
mat sigma_epsilon = B*sigma_e*B'
mat P1 = cholesky(sigma_epsilon)
mat list P1

* estimate inverse of B
qui reg e2 e1
global B21 = -e(b)[1,1]
qui reg e3 e1 e2
global B31 = -e(b)[1,1]
global B32 = -e(b)[1,2]
* construct matrix B
mat B = (1,0,0 \ $B21,1,0 \ $B31,$B32,1)
mat list B


* estimate IRFs, OIRFs, and SIRFs
mat irf0 = I($numnames)
mat sirf0 = irf0*inv(B)*P1
mat oirf0 = irf0*P
forvalues i=1/15{
	mat irf`i' = J($numnames,$numnames,0)
	forvalues j = 1/$lagorder{
	if `i' >= `j'{
	local temp = `i'-`j'
	mat temp2 = irf`temp'*A`j'
	mat irf`i' = irf`i'+ temp2
}
}
	mat sirf`i' = irf`i'*inv(B)*P1
	mat oirf`i' = irf`i'*P
}


* collect irf matrix into dataset fullirfs.dta
cap program drop reshapemat 
cap program define reshapemat
cap mat drop c`1'
forvalues i=0/15{
	mat colnames `1'`i' = $names
	mat rownames `1'`i' = $names
	mat temp1=vec(`1'`i')
	mat c`1' = nullmat(c`1') \ temp1
}
mat colnames c`1' = "`1'"
end

local irfnames "irf sirf oirf"
cap mat drop fullirfs
foreach name in `irfnames'{
	reshapemat  `name'
	mat fullirfs = (nullmat(fullirfs), c`name')
}
mat list fullirfs

clear
svmat fullirfs, names(col)
g rownames = ""
local rownames : rowfullnames coirf
local c : word count `rownames'
forvalues i = 1/`c' {
    qui replace rownames = "`:word `i' of `rownames''" in `i'
}

split rownames, p(":")
rename rownames2 response
rename rownames1 impulse
drop rownames

g step = floor((_n-1)/9)
save fullirfs, replace

* calculate mse and fevd, save them into dataset fevds.dta
use fullirfs, replace
* calculate the sqaured irfs
g sqoirf = oirf^2
* calculate the MSE of each step
sort step response impulse
by step response: egen temp = sum(sqoirf)
sort response impulse step
by response impulse: g mse = sum(temp)
by response impulse: g cvarcontri = sum(sqoirf)
g fevd_manual = cvarcontri/mse
keep step response impulse mse fevd_manual
replace step = step +1 
save fevds, replace

**#  generate benchmark using `svar' command
use varsample.dta, clear
tsset yq
matrix A1 = (1,0,0 \ .,1,0 \ .,.,1)
matrix B1 = (.,0,0 \ 0,.,0 \ 0,0,.)
svar $names, lags(1/7) aeq(A1) beq(B1)
irf create forblog, step(15) set(myirf) replace
mat sigma_e_bench = e(Sigma)
mat B_bench = e(A)
mat beta_bench = e(b_var)

**# Compare manually computed results with benchmark
* check variance-covariance matrix
mat list sigma_e
mat list sigma_e_bench

* check matrix B
mat list B
mat list B_bench

* check reduced-form coefficients
mata
	beta_bench = st_matrix("beta_bench")
	beta_bench = rowshape(beta_bench, $numnames)'
	st_matrix("beta_bench", beta_bench)
end

mat betas = (beta, beta_bench)
mat list betas

* check irfs
use myirf.irf, replace
rename *irf b*irf
joinby impulse response step using fullirfs
order impulse response step birf irf boirf oirf bsirf sirf
format *irf %6.0g
list impulse response step birf irf boirf oirf bsirf sirf in 1/18

* check fevd
use myirf.irf, replace
rename fevd bfevd
g bmse = mse^2
rename mse rmse
joinby impulse response step using fevds
order impulse response step bfevd fevd_manual bmse mse
list impulse response step bfevd fevd_manual bmse mse in 1/18
```



## Summary

In this blog, I firstly theoretically defined the computations of reduced-form coefficients, IRF, OIRF, SIRF, MSE, and FEVD of the VAR model. Then I manually computed all the above outputs in Stata following their theoretical definitions. Finally, I compare my manually computed outputs with the outcomes produced by the integrated command `svar` to check the validity of my calculations.

While anyone can produce the above results with the integrated command `svar` in seconds, how are these results are produced is unclear for many people and deter them from confidently using the VAR outputs in their own research. I hope this blog can help to mitigate this issue and help my readers gain more thorough understanding about VAR estimation and more confidently use the outputs of VAR estimation. 

## Reference

1. Lütkepohl, Helmut. "New Introduction to Multiple Time Series Analysis." (2007).
2. Enders, Walter. "Applied Econometric Time Series, 2nd Edition"  (2004) .
