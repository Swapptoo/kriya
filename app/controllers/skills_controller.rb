class SkillsController < ApplicationController
  def search
    @skills = Skill.where('skill iLIKE ?', "%#{params[:query]}%").limit(25) if params[:query]
    respond_to do |format|
      format.json {
        render :json => { results: @skills.map{ |s| { name: s.skill, value: s.id } }, success: true }
      }
    end
  end
end
