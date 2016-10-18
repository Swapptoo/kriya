class SkillsController < ApplicationController
  def search
    @skills = []
    @skills = Skill.where('skill iLIKE ?', "#{params[:query]}%").limit(25) if params[:query].present?
    respond_to do |format|
      format.json {
        render :json => { results: @skills.map{ |s| { name: s.skill, value: s.id } }, success: true }
      }
    end
  end
end
