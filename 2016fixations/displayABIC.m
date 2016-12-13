% function displayABIC(aic,bic, k, nK, Sigma, nSigma, nSC)
figure;
bar(reshape(aic,nK,nSigma*nSC));
title('AIC For Various $k$ and $\Sigma$ Choices','Interpreter','latex');
xlabel('$k$','Interpreter','Latex');
ylabel('AIC');
legend({'Diagonal-shared','Full-shared','Diagonal-unshared',...
    'Full-unshared'});

figure;
bar(reshape(bic,nK,nSigma*nSC));
title('BIC For Various $k$ and $\Sigma$ Choices','Interpreter','latex');
xlabel('$c$','Interpreter','Latex');
ylabel('BIC');
legend({'Diagonal-shared','Full-shared','Diagonal-unshared',...
    'Full-unshared'});