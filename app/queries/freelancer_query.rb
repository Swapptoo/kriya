class FreelancerQuery
  attr_reader :freelancers

  def initialize(skill_ids = [])
    @skill_ids = skill_ids

    if @skill_ids.empty?
      @freelancers = Freelancer.none
    else
      freelancers = Freelancer.where(primary_skill: @skill_ids)

      if freelancers.size < 50
        freelancer_ids = FreelancerSkill.where.not(freelancer_id: freelancers.ids).where(skill_id: @skill_ids).limit(50 - freelancers.size).distinct.pluck(:freelancer_id)
        @freelancers = Freelancer.where(id: (freelancers.ids + freelancer_ids).uniq)
      else
        @freelancers = freelancers
      end
    end
  end
end
