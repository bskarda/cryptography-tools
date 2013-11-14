def cycle(a, b, ct)
	used = ""
	#loop though each word of ciphertext
	ct.each do |word|
		cur = word
		# check to see if the character has been used. If so skip it.
		if(!used.include?(cur[a]))
			#p cur[a]
			# string of the cycle
			String cyc = ""
			# Set the first letter of the cycle to the first letter of the ct
			cyc << cur[a]
			#loop while the sequnece has not repeated
			while (!cyc.include?(cur[b])) do
				#p cur
				#get the set of possible net letters
				possible = ct.select {|x| x[a] == cur[b]}
				#p possible
				#p "cur[b] = #{cur[b]} cyc = #{cyc}"
				if (possible.length > 0)
					# add the next letter of the squence to the cycle
					cur = possible[0]
					cyc << cur[a]

				else
					# make sure the while loop dies
					cur[b] = cyc[0]
					p "possible error"
				end
			end
			used << cyc
			p "Cycle => #{cyc} length of #{cyc.length}"
		end
	end
end


str = "GAWGST OTJPNA VBPLKM YPSYVU CZSXGU HTNINR PCLSOI WMGREH YPSYVU CZSXGU HIZIMP PCLSOI WMGREH YPSYVU CZSXGU IOQHFZ QNHDPB XPRCVD YAMYSL CQOXQQ JJHBJB QNHDPB XPRCVD YAMYSL DXYMTS KPVOVY RJXNJK XPRCVD ZSTKHE DXYMTS LHXQRK RJXNJK XPRCVD ZSTKHE DUOMAQ MVHFYB SGCADV XLICWW ZGGKDH DECMIV NTUZNJ SGCADV YEDYIC AYKTCN EVIUYW NTUZNJ TDJWZA YEDYIC BOOVFQ EVIUYW NDBZZO TDJWZA YEFYIC BOOVFQ FFEEXG OQMPQL TRAWLF YEDYIC BWFVBX FKLEUI OQMPQL UHAJRF YEDYIC BWFVBX FYPECM"

#split the given keys into an array of words where each word is an array of letters
ct = str.split(' ').map {|x| x.split(//)}

#p ct

p "DoA"
cycle(0,3,ct)
p "EoB"
cycle(1,4,ct)
p "FoC"
cycle(2,5,ct)
