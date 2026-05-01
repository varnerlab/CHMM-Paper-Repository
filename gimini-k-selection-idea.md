A combination metric is strongly recommended. Relying solely on the Kolmogorov-Smirnov (KS) test is structurally insufficient for evaluating synthetic daily returns because it is entirely blind to the sequence of events. 

Here is a breakdown of why a composite approach targeting both distribution and temporal dependence is the most robust methodology for evaluating synthetic generators against the core stylized facts.

### 1. The "Time-Blindness" of KS
The KS test measures the maximum distance between two empirical cumulative distribution functions (CDFs). It evaluates *marginal distribution fidelity* but contains zero information about temporal order. 

If a model generates a highly realistic synthetic return path with perfect volatility clustering, and you randomly shuffle the order of those daily returns, the shuffled series will receive the exact same KS score as the original. Because the slow decay of the absolute-return autocorrelation function (ACF) is a strict requirement for modeling market memory, any evaluation metric must explicitly penalize the loss of temporal dependence. Incorporating the absolute-return ACF Mean Absolute Error (MAE) solves this critical blind spot.

### 2. The Tail-Sensitivity Problem (KS vs. AD)
Even for the purely distributional component, KS has a well-known mathematical limitation: it is highly sensitive to discrepancies near the median of the distribution but loses sensitivity at the extremes. 

When attempting to accurately replicate the heavy-tailed nature of financial returns, capturing extreme events (high kurtosis) is essential. The Anderson-Darling (AD) statistic is generally superior for this specific task because it applies a weighting function that heavily penalizes divergences in the tails. 

Alternatively, moving toward continuous quantitative scoring metrics, such as the **Wasserstein distance** or **Kullback-Leibler (KL) divergence**, often provides a more robust and granular measure of distributional fidelity than the rigid step-functions evaluated by KS or AD. Wasserstein distance, in particular, treats the distributions as geometric spaces, offering a highly stable scoring metric for how much "work" it takes to transform the synthetic distribution into the historical one, tails included.

### 3. The Composite Objective
To comprehensively score a synthetic data generator, the objective function must explicitly demand both spatial and temporal accuracy. A weighted composite metric elegantly handles this:

$$\text{Total Error} = \alpha \cdot \text{Distributional Penalty} + (1-\alpha) \cdot \text{ACF}_{|r|} \text{ Penalty}$$

* **Distributional Penalty:** Evaluated via AD, Wasserstein distance, or KL divergence to ensure the synthetic generator accurately produces heavy tails without relying solely on KS pass rates.
* **ACF Penalty:** Evaluated via the MAE of the absolute-return ACF across the first $L$ lags to ensure the generator replicates the exact temporal memory and volatility clustering of the observed market.

By combining these, you prevent the model from "cheating" by optimizing for a perfect static distribution at the expense of realistic time-series dynamics.