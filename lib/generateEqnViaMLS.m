function [z] = generateEqnViaMLS(x,y,deg)
  degree = deg + 1;
  row_vec = zeros(degree,degree);
  col_vec = zeros(degree,1);
  %row vector
  for idx = 1:degree
    for odx = 0:degree-1
        for jdx = 1:length(x)
           row_vec(idx,odx+1) = row_vec(idx,odx+1) + x(jdx)^(odx+idx-1);
        end
    end
  end
  
  
  %column vector
  for idx = 1: degree
    for odx = 1 : length(y)
        col_vec(idx) = col_vec(idx) + x(odx)^(idx-1)*y(odx);
    end
  end
  
  %Inverse Matrix
  inv_mat = inv(row_vec);
  z = inv_mat * col_vec;
end