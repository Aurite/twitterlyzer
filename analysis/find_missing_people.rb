require '../config/environment'
require 'faster_csv'

#Log 04.04 Dumping first networks
#@@communities = [4, 6, 9, 13, 17, 19, 21, 25, 27, 31, 33, 39, 44, 46, 48, 56, 62, 70, 72, 82, 86, 94, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111]
#Log 05.05 Dumping more networks
#@@communities += [112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 123, 137, 141, 143, 145, 149, 153, 155, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 170, 171, 172, 174, 175, 176, 177, 178, 179, 180, 181, 187, 189, 207, 209, 211, 213, 217, 219, 221, 233, 245, 247, 251, 253, 255, 257, 259, 261, 263, 265, 271, 275, 279, 281, 285, 291, 293, 297, 303, 305, 307, 311, 315, 317, 319]
#323 segfault
#@@communities += [325, 327, 329, 333, 337, 339, 341, 351, 353, 355, 357, 359, 361, 365, 367, 369, 371, 373, 379, 385, 387, 389, 391, 395, 397, 399, 401, 403, 405, 407]

missing_persons = File.open("results/missing_persons_new.csv","w+")

sorted_members ={}
@@communities.each do |community|  
  project = Project.find(community)
  puts "Reading in project #{project.name}"
  sorted_members[project.name] = {:community => community, :list => FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")[1..100]} #skip header  
end

sorted_members.each do |key,value|
  value[:list].each do |member|
    if Person.find_by_username(member[0]) == nil      
      missing_persons.puts "#{value[:community]}, #{key}, #{member[0]}"
      maxfriends = 100000
      category = ""
      Delayed::Job.enqueue(CollectPersonJob.new(member[0],value[:community],maxfriends,category))
    end
  end
end

missing_persons.close