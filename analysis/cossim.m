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
	
	dblCosSim = dot(vec1,vec2)/(norm(vec1)*norm(vec2));
	if nargout > 1
		dblAngSim = 1-2*acos(dblCosSim)/pi;
	end
end

