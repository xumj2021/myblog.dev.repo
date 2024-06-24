---
title:       "Touch into the Vector Auto Regression Model"
subtitle:    ""
description: "The logics of VAR, Impulse Reaction, and Variance Decomposition"
date:        2022-11-22
author:      "Mengjie Xu"
toc:         true
image:    "https://assets.bbhub.io/image/v1/resize?type=auto&url=https%3A%2F%2Fassets.bbhub.io%2Fprofessional%2Fsites%2F10%2F385236110.jpg"
tags:        ["Time series", "VAR"]
categories:  ["Theory"]
---

## Motivation
In [my last blog](https://mengjiexu.com/post/an-information-based-decomposition-of-stock-price/), I recognized the potential of the information-based variance decomposition method introduced by Brogaard et al. (2022, RFS) and showed interests of applying this method into my own research.

As replicating Brogaard et al. (2022, RFS) requires some manipulations on the VAR estimation outputs, I took some time to figure out the theory and estimation of the reduced-form VAR coefficients, Impulse response functions (IRFs), structural IRFS, orthogonalized IRFs, and variance decomposition.

I summarized what've got in three blogs. In [the first blog](https://mengjiexu.com/post/touch-into-var/), I  show the basic logics of VAR model with the simplest 2-variable, 1-lag VAR model. In [the second blog](https://mengjiexu.com/post/common-practice-of-var-estimation-in-stata/), I show how to use `var` and `svar` commands to conveniently estimate the VAR model in Stata. In [the third blog](https://mengjiexu.com/post/manually-replicate-statas-practice-in-estimations-of-var-irfs-and-variance-decomposition/), I will dig deeper, show the theoretical definitions and calculation formula of major outputs in VAR model, and manually calculate them in Stata to thourougly uncover the black box of the  VAR estimation.

This blog is the first one among my VAR blog series. In this blog, I summarized the logics of VAR, Impulse Reaction, and Variance Decomposition with the simplest 2-variable, 1-lag VAR model. The following summary is based on PP.264-PP.311 of Enders (2004). 

## VAR in structural and reduced form

Consider *a bivariate structural VAR system* composed by two \\(I(0)\\) series \\(\{y_{t}\}\\) and \\(\{z_{t}\}\\)

$$
\begin{aligned}
y_t&=b_{10}-b_{12} z_t+\gamma_{11} y_{t-1}+\gamma_{12} z_{t-1}+\epsilon_{y t} \\\\\\
z_t&=b_{20}-b_{21} y_t+\gamma_{21} y_{t-1}+\gamma_{22} z_{t-1}+\epsilon_{z t}
\end{aligned} \tag{1}
$$

where \\(\{\epsilon_{y t}\}\\) and \\(\{\epsilon_{z t}\}\\) are uncorrelated white-noise disturbances.

*This is not a VAR in reduced form since \\(y_{t}\\)  and \\(z_{t}\\) has a contemporaneous effect on each other*.

Represent Equation (1) in a compact form

$$
B x_t=\Gamma_0+\Gamma_1 x_{t-1}+\epsilon_t \tag{2}
$$

where 

$$
\begin{aligned}
&B=\left[\begin{array}{cc}
1 & b_{12} \\\\\\
b_{21} & 1
\end{array}\right], \quad x_t=\left[\begin{array}{l}
y_t \\\\\\
z_1
\end{array}\right], \quad \Gamma_0=\left[\begin{array}{l}
b_{10} \\\\\\
b_{20}
\end{array}\right] \\\\\\
&\Gamma_1=\left[\begin{array}{ll}
\gamma_{11} & \gamma_{12} \\\\\\
\gamma_{21} & \gamma_{22}
\end{array}\right], \quad \epsilon_t=\left[\begin{array}{l}
\epsilon_{y t} \\\\\\
\epsilon_{z t}
\end{array}\right] \\\\\\
&
\end{aligned}
$$

*Pre-multiply \\(B^{-1}\\) to obtain VAR model in standard (reduced) form*

$$
x_t=A_0+A_1 x_{r-1}+e_t \tag{3}
$$

where

$$
\begin{aligned}&A_0=B^{-1} \Gamma_0 \\\\\\
&A_1=B^{-1} \Gamma_1 \\\\\\
&e_1=B^{-1} \epsilon_1\end{aligned}
$$

in this special case

$$
B^{-1}=\frac{1}{1-b_{12} b_{21}}\left[\begin{array}{cc}
1 & -b_{12} \\\\\\
-b_{21} & 1
\end{array}\right]
$$

and thus 

$$
\left[\begin{array}{l}
e_{y t} \\\\\\
e_{z t}
\end{array}\right]=B^{-1}\left[\begin{array}{l}
\epsilon_{y t} \\\\\\
\epsilon_{z t}
\end{array}\right]=\left[\begin{array}{l}
\left(\epsilon_{y t}-b_{12} \epsilon_{2 t}\right) /\left(1-b_{12} b_{21}\right) \\\\\\
\left(\epsilon_{z t}-b_{21} \epsilon_{y t}\right) /\left(1-b_{12} b_{21}\right)
\end{array}\right]\tag{4}
$$

### Identification logic

- as in the reduced form, the right hand side only contains predetermined variables and the error terms are assumed to be serially uncorrelated with constant variance, *each equation in the reduced-form system can be estimated using OLS.*

  - the latter feature is obtained because the disturbance terms are assumed to be uncorrelated white noise series, which results

    $$
    E e_{1t} e_{1 t-i}=E\frac{\left[\left(\epsilon_{y t}-b_{12} \epsilon_{2 t}\right)\left(\epsilon_{y t-i}-b_{12} \epsilon_{z t-i}\right)\right]}{\left(1-b_{12} b_{21}\right)^2}=0,
    \forall i \neq 0
    $$

  - the OLS estimation is proved to be consistent and asymptotically efficient in reduced form

- however, we care about how does the innovations cause contemporaneous changes in focal variables

- thus, the typical logic of VAR estimation is to employ OLS to *estimate the reduced-form VAR first*, and then *back out the coefficients in the structural VAR using the parameters estimated in the reduced-form VAR*

### Identification Techniques

#### Necessity of adding restrictions for identification

Consider a first-order VAR model with \\(n\\) variables *(the identification procedure is invariant to lag length)*.

$$
\left[\begin{array}{ccccc}
1 & b_{12} & b_{13} & \ldots & b_{1 n} \\\\\\
b_{21} & 1 & b_{23} & \ldots & b_{2 n} \\\\\\
\cdot & . & \cdot & . & \cdot \\\\\\
b_{n 1} & b_{n 2} & b_{n 3} & \ldots & 1
\end{array}\right]\left[\begin{array}{l}
x_{11} \\\\\\
x_{2 t} \\\\\\
\cdots \\\\\\
x_{n t}
\end{array}\right]=\left[\begin{array}{c}
b_{10} \\\\\\
b_{20} \\\\\\
\ldots \\\\\\
b_{n 0}
\end{array}\right]+\left[\begin{array}{ccccc}
\gamma_{11} & \gamma_{12} & \gamma_{13} & \ldots & \gamma_{1 n} \\\\\\
\gamma_{21} & \gamma_{22} & \gamma_{23} & \ldots & \gamma_{2 n} \\\\\\
\cdot & \cdot & \cdot & \cdot & \cdot \\\\\\
\gamma_{n 1} & \gamma_{n 2} & \gamma_{n 3} & \ldots & \gamma_{n n}
\end{array}\right]\left[\begin{array}{c}
x_{1 t-1} \\\\\\
x_{2 t-1} \\\\\\
\ldots \\\\\\
x_{n t-1}
\end{array}\right]+\left[\begin{array}{c}
\epsilon_{1 t} \\\\\\
\epsilon_{2 t} \\\\\\
\ldots \\\\\\
\epsilon_{n t}
\end{array}\right] \tag{5}
$$
or in compact form

$$
B x_t=\Gamma_0+\Gamma_1 x_{t-1}+\epsilon_t \tag{6}
$$

pre-multiply (5) with \\(B^{-1}\\) and get the reduced form

$$
x_t=B^{-1} \Gamma_0+B^{-1} \Gamma_1 x_{t-1}+B^{-1} \epsilon_t \tag{7}
$$

in practice, we use OLS to estimate each regression in system (6) and get the variance-covariance matrix \\(\Sigma\\)

$$
\Sigma=\left[\begin{array}{cccc}\sigma_1^2 & \sigma_{12} & \ldots & \sigma_{1 n} \\\\\\
\sigma_{21} & \sigma_2^2 & \ldots & \sigma_{2 n} \\\\\\
\cdot & \cdot & . & . \\\\\\
\sigma_{n 1} & \sigma_{n 2} & \ldots & \sigma_n^2\end{array}\right]
$$

since \\(\Sigma\\) is symmetric, we can only get \\((n^2+n)/2\\) distinct equations for identification.

however, the identification of \\(B\\) needs \\(n^2\\) conditions.

Thus, *we need to impose \\(n^2-(n^2+n)/2=(n^2-n)/2\\) restrictions to matrix \\(B\\) to exactly identify the structural model from an estimation of the reduce-form VAR.*

The way of adding restrictions can differ with economic contexts, but there are mainly two prevalent procedures in use.

#### Sims-Bernanke procedure

- this procedure is represented by Sims (1986) and Bernanke (1986).

- *in this procedure, the scholars force all elements above the principal diagonal of \\(B^{-1}\\) to be 0, which is also called **Cholesky decomposition***

  $$
  \begin{gathered}
  b_{12}=b_{13}=b_{14}=\cdots=b_{1 n}=0 \\\\\\
  b_{23}=b_{24}=\cdots=b_{2 n}=0 \\\\\\
  b_{34}=\cdots=b_{3 n}=0 \\\\\\
  \cdots \\\\\\
  b_{n-1 n}=0
  \end{gathered}
  $$

- by doing this, there are \\((n^2-n)/2\\) restrictions manually imposed to the matrix \\(B\\), which facilitates the exact identification of \\(B\\)

#### Blanchard-Quach procedure

- this procedure is represented by Blanchard and Quach (1989), which reconsidered the Beveridge and Nelson (1981) decomposition of real GNP into its temporary and permanent components
  - an especially useful feature of the technique is that it provides a unique *decomposition of an economic time series into its temporary and permanent components*
- differences from Sims-Bernanke procedure
  - at least one variables to be nonstationary since \\(I(0)\\) do not have a permanent component
  - do not directly associate the \\(\{\varepsilon_{1t}\}\\) and \\(\{\varepsilon_{2t}\}\\) shocks with the \\(\{y_t\}\\) and \\(\{z_t\}\\) variables
- *the key to decomposing the \\(\{y_t\}\\) sequence (or other non-stationary sequences in the VAR system) into its permanent and stationary components is to assume that at least one of the shocks has a temporary effect on the \\(\{y_t\}\\) sequence, which allows the identification of the structural VAR*

##### Example

- to illustrate the idea better, consider a bivariate VAR system with \\(\{y_t\}\\)  being a \\(I(1)\\) series. write it into a VMA form as follows.

  $$
  \begin{aligned}
  \Delta y_t &=\sum_{k=0}^{\infty} c_{11}(k) \epsilon_{1 t-k}+\sum_{k=0}^{\infty} c_{12}(k) \epsilon_{2 t-k} \\\\\\
  z_t &=\sum_{k=0}^{\infty} c_{21}(k) \epsilon_{1 t-k}+\sum_{k=0}^{\infty} c_{22}(k) \epsilon_{2 t-k}
  \end{aligned} 
  $$

- the key assumption of Blanchard-Quach procedure is that *the cumulated effect of the shock \\(\{\varepsilon_{1t}\}\\) on the \\(\Delta y_t\\) sequence must be equal to zero*, for any possible realization of the \\(\{\varepsilon_{1t}\}\\) sequence

  $$
  \sum_{k=0}^{\infty} c_{11}(k) \epsilon_{1 t-k}=0
  $$

- this restrictions combined with the three distinct variance-covariance parameters \\(var(e_1), var(e_2), cov(e_1,e_2)\\)  estimated from the reduced-form VAR can achieve the exact identification of the \\(2\times2\\) matrix \\(B\\)  in this bivariate VAR system

    

### Impulse response

#### Logic of impulse response

- the idea of impulse response is to *trace the effects of a one-unit shock in \\(\epsilon_{y t}\\) and \\(\epsilon_{z t}\\) on the time paths of the \\(\{y_{t}\}\\) and \\(\{z_{t}\}\\) sequences*
- to achieve this goal, it would be more convenient to represent \\(\{y_{t}\}\\) and \\(\{z_{t}\}\\) sequences using the \\(\{\epsilon_{y t}\}\\) and \\(\{\epsilon_{z t}\}\\) sequences, which means *transferring VAR to a VMA model*
- to illustrate the intuition better, the derivation of the impulse response function will still be based on the bivariate VAR system

#### From VAR to VMA

- start from the reduced-form VAR represented by equation (3)

  $$
  x_t=A_0+A_1 x_{r-1}+e_t
  $$

- iterate the above equation to obtain

  $$
  x_t =A_0+A_1\left(A_0+A_1 x_{t-2}+e_{t-1}\right)+e_t =\left(I+A_1\right) A_0+A_1^2 x_{t-2}+A_1 e_{t-1}+e_t
  $$

- after \\(n\\) iterations

  $$
  x_t=\left(I+A_1+\cdots+A_1^n\right) A_0+\sum_{i=0}^n A_1^i e_{t-i}+A_1^{n+1} x_{t-n-1}
  $$

- if \\(x_t\\) should converge, then the term \\(A^n\\) needs to vanish as \\(n\\) approaches infinity

- assume the stability condition is met, we can write the VAR model in a VMA form

  $$
  x_t=\mu+\sum_{i=0}^{\infty} A_1^i e_{t-i} \tag{8}
  $$

  where \\(\mu=\left[\begin{array}{ll}\bar{y} & \bar{z}\end{array}\right]^{\prime}\\)

  and 

  $$
  \begin{aligned}&\bar{y}=\left[a_{10}\left(1-a_{22}\right)+a_{12} a_{20}\right] / \Delta, \quad \bar{z}=\left[a_{20}\left(1-a_{11}\right)+a_{21} a_{10}\right] / \Delta \\\\\\
  &\Delta=\left(1-a_{11}\right)\left(1-a_{22}\right)-a_{12} a_{21}\end{aligned}
  $$

  note that \\(\mu\\) can be calculated by applying the following formula

  $$
  I+A_1+...+A_1^n = [I-A_1]^{-1} 
  $$

#### From VMA to impulse response function

- start from equation (8), which is the VMA representation of VAR model

  $$
  x_t=\mu+\sum_{i=0}^{\infty} A_1^i e_{t-i} 
  $$

- write in a loose form

  $$
  \left[\begin{array}{l}
  y_t \\\\\\
  z_t
  \end{array}\right]=\left[\begin{array}{l}
  \bar{y} \\\\\\
  \bar{z}
  \end{array}\right]+\sum_{i=0}^{\infty}\left[\begin{array}{ll}
  a_{11} & a_{12} \\\\\\
  a_{21} & a_{22}
  \end{array}\right]^i\left[\begin{array}{l}
  e_{1 t-i} \\\\\\
  e_{2 t-i}
  \end{array}\right] \tag{9}
  $$

- recall from equation (4) the relationship between reduced-form error term and the innovations

  $$
  \left[\begin{array}{l}
  e_{1 t} \\\\\\
  e_{2 t}
  \end{array}\right]=B^{-1}\left[\begin{array}{l}
  \epsilon_{y t} \\\\\\
  \epsilon_{z t}
  \end{array}\right]=\frac{1}{1-b_{12} b_{21}}\left[\begin{array}{cc}
  1 & -b_{12} \\\\\\
  -b_{21} & 1
  \end{array}\right]\left[\begin{array}{c}
  \epsilon_{y t} \\\\\\
  \epsilon_{z t}
  \end{array}\right] \tag{10}
  $$

- the VMA representation of VAR model can be rewritten in terms of \\(\{\epsilon_{y t}\}\\) and \\(\{\epsilon_{z t}\}\\) sequences by plugging (10) into (9), which is also called the impulse response functions

- use \\(\phi_{ij}(k)\\) to represent the impulse response coefficients

  $$
  \left[\begin{array}{l}
  y_t \\\\\\
  z_t
  \end{array}\right]=\left[\begin{array}{l}
  \bar{y} \\\\\\
  \bar{z}
  \end{array}\right]+\sum_{i=0}^{\infty}\left[\begin{array}{ll}
  \phi_{11}(i) & \phi_{12}(i) \\\\\\
  \phi_{21}(i) & \phi_{22}(i)
  \end{array}\right]\left[\begin{array}{l}
  \epsilon_{y t-i} \\\\\\
  \epsilon_{z t-i}
  \end{array}\right]
  $$

- in a compact format

  $$
  x_t=\mu+\sum_{i=0}^{\infty} \phi_i \epsilon_{t-i} \tag{11}
  $$

- the accumulated effects of unit impulses in \\(\epsilon_{y t}\\) and \\(\epsilon_{z t}\\) can be obtained by appropriate summation of the coefficients of the impulse response functions

  - for example, after \\(n\\) periods, the cumulated sum of effects of \\(\epsilon_{zt}\\) on the \\(\{y_t\}\\) sequence is

    $$
    \sum_{i=0}^n \phi_{12}(i)
    $$

#### Confidence intervals of impulse response coefficients

- draw \\(T\\), which is the sample size, random numbers so as to represent \\(\{\epsilon\}\\) sequence and then use it combined with the naive estimation of reduced-form VAR to construct \\(\{\hat{x}\}\\) series, then estimate the impulse response function
- repeat the above procedure for 1000 times or more and use the realized impulse response coefficients to get bootstrap confidence intervals

### Variance decomposition

- start from equation (9), which is the impulse response equations

  $$
  x_t=\mu+\sum_{i=0}^{\infty} \phi_i \epsilon_{t-i} 
  $$

- suppose now we are forecast the \\(n\\) periods after \\(t\\)

  $$
  x_{t+n}=\mu+\sum_{i=0}^{\infty} \phi_i \epsilon_{t+n-i} 
  $$

- as both \\(\{\epsilon_{y t}\}\\) and \\(\{\epsilon_{z t}\}\\) are white-noise disturbances, the \\(n\\)-period forecast error is

  $$
  x_{t+n}-E_t x_{t+n}=\sum_{i=0}^{n-1} \phi_i \epsilon_{t+n-i} \tag{12}
  $$

- take the \\(\{y_t\}\\) sequence as an example, the \\(n\\)-period forecast error is

  $$
  \begin{gathered}
  y_{t+n}-E_t y_{t+n}=\phi_{11}(0) \epsilon_{y t+n}+\phi_{11}(1) \epsilon_{y t+n-1}+\cdots+\phi_{11}(n-1) \epsilon_{y t+1} \\\\\\
  +\phi_{12}(0) \epsilon_{z t+n}+\phi_{12}(1) \epsilon_{z t+n-1}+\cdots+\phi_{12}(n-1) \epsilon_{z t+1}
  \end{gathered}
  $$

- denote the \\(n\\)-step-ahead forecast error variance of \\(y_{t+n}\\) as \\(\sigma_y(n)^2\\)

  $$
  \sigma_y(n)^2=\sigma_y^2\left[\phi_{11}(0)^2+\phi_{11}(1)^2+\cdots+\phi_{11}(n-1)^2\right]+\sigma_z^2\left[\phi_{12}(0)^2+\phi_{12}(1)^2+\cdots+\phi_{12}(n-1)^2\right]
  $$

- thus, it’s possible to decompose the \\(n\\)-step-ahead forecast error variance into proportions due to innovations in \\(\{\epsilon_{y t}\}\\) and \\(\{\epsilon_{z t}\}\\) respectively

  $$
  \begin{gathered}\frac{\sigma_y^2\left[\phi_{11}(0)^2+\phi_{11}(1)^2+\cdots+\phi_{11}(n-1)^2\right]}{\sigma_y(n)^2} \\\\\\
  \frac{\sigma_z^2\left[\phi_{12}(0)^2+\phi_{12}(1)^2+\cdots+\phi_{12}(n-1)^2\right]}{\sigma_y(n)^2}\end{gathered}
  $$


## Reference
1. Enders, Walter. "Applied Econometric Time Series. 2th ed." *New York (US): University of Alabama* (2004).