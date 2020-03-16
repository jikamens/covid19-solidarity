class RequestsController < ApplicationController
  protect_from_forgery prepend: true
  before_action :authenticate_user!, except: [:show]

  def index
    if current_user.admin?
      @requests = Request.all.order('created_at DESC')
    else
      @requests = current_user.requests.order('created_at DESC')
    end
  end

  def show
    @request = Request.friendly.find(params[:id])
  end

  def new
    @request = Request.new
    @request.user = current_user
  end

  def edit
    @request = Request.friendly.find(params[:id])
    if not (current_user.try(:admin?) or
            current_user.try(:id) == @request.user_id)
      not_found
    end
  end

  def create
    if not current_user
      not_found
    end
    msg = nil
    u = nil
    if current_user.admin? and params[:request][:email].present?
      email = params[:request][:email]
      u = User.where(:email => email).first
      if not u
        good = false
        msg = email + ' not found in database'
      elsif u.requests.find { |r| r.closed_at.nil? }
        good = false
        msg = email + ' already has an open request'
      end
    end
    @request = Request.new(request_params)
    @request.user = u || current_user
    @request.created_by = current_user.id
    if msg
      @request.valid? # Populate errors
      @request.errors.add(:email, msg)
      render 'new'
    elsif @request.save
      redirect_to @request
    else
      render 'new'
    end
  end

  def update
    @request = Request.friendly.find(params[:id])
    if not (current_user.try(:admin?) or
            current_user.try(:id) == @request.user_id)
      not_found
    end

    if params[:request][:closing] == 'yes'
      if params[:commit] == 'Close request'
        @request.closed_at = Time.now
        @request.save
      end
      redirect_to requests_path and return
    end
    
    if @request.update(request_params)
      @request.updated_by = current_user.id
      @request.save
      redirect_to @request
    else
      render 'edit'
    end
  end

  def destroy
    if not current_user.admin?
      not_found
    end
    @request = Request.friendly.find(params[:id])
    @request.destroy
    if current_user.admin? or Request.where(:user => current_user).first
      redirect_to requests_path
    else
      redirect_to root_path
    end
  end

  def close
    @request = Request.friendly.find(params[:request_id])
    if not (current_user.try(:admin?) or
            current_user.try(:id) == @request.user_id)
      not_found
    end
  end

  private

  def request_params
    params.require(:request).permit(:name, :contact_info, :payment_info,
                                    :amount, :description, :zip_code)
  end

  def check_completed
    # XXX Can't build this until contributions are implemented
  end
end
