class Admin::EventRegistrationsController < AdminController

  before_action :find_event

  def index
    @registrations = @event.registrations.includes(:ticket).order("id DESC").page(params[:page]).per(10)

    if params[:status].present? && Registration::STATUS.include?(params[:status])
      @registrations = @registrations.by_status(params[:status])
    end

    if params[:ticket_id].present?
      @registrations = @registrations.by_ticket(params[:ticket_id])
    end

    if Array(params[:statuses]).any?
      @registrations = @registrations.by_status(params[:statuses])
    end

    if Array(params[:ticket_ids]).any?
      @registrations = @registrations.by_ticket(params[:ticket_ids])
    end

    if params[:start_on].present?
      @registrations = @registrations.where("created_at >= ?", Date.parse(params[:start_on]).beginning_of_day)
    end

    if params[:end_on].present?
      @registrations = @registrations.where("created_at <= ?", Date.parse(params[:end_on]).end_of_day)
    end

  end

  def new
    @registration = @event.registrations.new
  end

  def create
    @registration = @event.registrations.new(registration_params)
    @registration.event = @event
    @registration.ticket = @event.tickets.find(params[:registration][:ticket_id])
    @registration.status = "pending"
    @registration.user = current_user

    if @registration.save
      redirect_to admin_event_registrations_path(@event)
    else
      render "new"
    end
  end

  def show
    @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def edit
    @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def update
    @registration = @event.registrations.find_by_uuid(params[:id])
    if @registration.update(registration_params)
      redirect_to admin_event_registrations_path(@event)
    else
      render :edit
    end
  end

  def destroy
    @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.destroy

    redirect_to admin_event_registrations_path(@event)
  end

  protected

  def find_event
    @event = Event.find_by_friendly_id(params[:event_id])
  end

  def registration_params
    params.require(:registration).permit(:status, :ticket_id, :name, :email, :cellphone, :website, :bio)
  end

end
