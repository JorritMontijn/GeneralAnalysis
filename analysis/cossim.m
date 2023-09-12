function [dblCosSim,dblAngSim] = cossim(vec1,vec2)
    %cossim Cosine similarity between to vectors (range: [-1 1])
    %   [dblCosSim,dblAngSim] = cossim(vec1,vec2)
    %
    %where the outputs are defined as:
    %dblCosSim = dot(vec1,vec2)/(norm(vec1)*norm(vec2));
    %dblAngSim = 1-2*acos(dblCosSim)/pi;
    %
    %Note that the cosine similarity is not a true distance metric due to violating the Schwartz
    %inequality, but that the angular similarity, as defined above, is.

    intVecNum = size(vec1,2);
    dblCosSim = nan(1,intVecNum);
    dblAngSim = nan(1,intVecNum);
    for intVec=1:intVecNum
        dblCosSim(intVec) = dot(vec1(:,intVec),vec2(:,intVec))./(norm(vec1(:,intVec)).*norm(vec2(:,intVec)));
        if nargout > 1
            dblAngSim(intVec) = 1-2*acos(dblCosSim(intVec))/pi;
        end
    end
end

