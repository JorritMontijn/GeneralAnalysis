function sesNew = doSelectNeurons(ses,vecNeurons)
	%UNTITLED4 Summary of this function goes here
	%   Detailed explanation goes here
	sesNew = rmfield(ses, 'neuron');
	intNewCounter=0;
	for intNeuron=vecNeurons
		intNewCounter=intNewCounter+1;
		sesNew.neuron(intNewCounter) = ses.neuron(intNeuron);
	end
end

