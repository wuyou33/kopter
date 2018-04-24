%Script

%Define parameter variation range
m = 0.1:0.02:1;
lambda = 0:0.02:1;

k = 1;

t = 0:0.01:10;
rng(1); %random sed

u = randn(size(t));

g = @(y) y^2 + exp(1 - (0.1*y));

tic;

for i=1:length(lambda)

	for j=1:length(m)

		[X] = mass_spring_damper(m(j), lambda(i), k, u,t);
		J(i, j) = X.vars(2) + X.vars(1) + g(lambda(i)) + g(m(j));

	end

end

time = toc;

fprintf(['Time to compute: ' num2str(time) 's' '\n'])

% Find minima

[a, b] = min(J(:));
[R, C] = ind2sub(size(J), b);
lambda_0 = lambda(R);
m_0 = m(C);

% Plot all
[X, Y] = meshgrid(lambda, m);

figure('Units', 'normalized', 'Position', [0.15 0.1 0.7 0.75])

subplot(1, 2, 2)
contour(X,Y, J', 50)
hold on;
grid on
plot(lambda_0, m_0, 'ro', 'MarkerFaceColor', 'r')
xlabel('\lambda')
ylabel('m')
fprintf(['Minima cost function: ' num2str(J(R, C)) '\n'])
