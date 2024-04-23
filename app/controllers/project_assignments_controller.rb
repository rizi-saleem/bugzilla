# frozen_string_literal: true

class ProjectAssignmentsController < ApplicationController
  before_action :set_params, except: :new

  def new
    @user_type = params[:user_type]
    @project = Project.find(params[:project_id])
    @users = User.unassigned_users(params[:project_id]).with_role(@user_type)
    @project_assignment = ProjectAssignment.new

    authorize @project, :edit?
  end

  def create
    @project_assignment = ProjectAssignment.new(project_assignment_params)
    authorize @project_assignment

    if @project_assignment.save
      redirect_to project_path(@project),
                  notice: "#{@user.name} was successfully added to #{@project.name}."
    else
      render :new, alert: @project_assignment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @project_assignment = ProjectAssignment.find(params[:id])
    authorize @project_assignment

    if @project_assignment.destroy
      flash[:notice] = "#{@user.name} was successfully removed from #{@project.name}."
    else
      flash[:alert] = @project_assignment.errors.full_messages.to_sentence
    end
    redirect_to project_path(@project)
  end

  private

  def project_assignment_params
    params.permit(:user_id, :project_id)
  end

  def set_params
    @project = Project.find(params[:project_id])
    @user = User.find(params[:user_id])
    @user_type = params[:user_type]
  end
end
