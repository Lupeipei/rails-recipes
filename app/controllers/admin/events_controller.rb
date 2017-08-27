class Admin::EventsController < AdminController

  before_action :find_the_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = Event.rank(:row_order).all
  end

  def show
    colors = ['rgba(255, 99, 132, 0.2)',
              'rgba(54, 162, 235, 0.2)',
              'rgba(255, 206, 86, 0.2)',
              'rgba(75, 192, 192, 0.2)',
              'rgba(153, 102, 255, 0.2)',
              'rgba(255, 159, 64, 0.2)'
              ]
    ticket_names = @event.tickets.map { |t| t.name }

    @data1 = {
      labels: ticket_names,
      datasets: [{
        label: "# of Registrations ",
        data: @event.tickets.map {|t| t.registrations.count},
        backgroundColor: colors,
        borderWidth: 1
        }]
    }

    @data2 = {
      labels: ticket_names,
      datasets: [{
        label: "# of Amount ",
        data: @event.tickets.map {|t| t.registrations.by_status("confirmed").count * t.price},
        backgroundColor: colors,
        borderWidth: 1
        }]
    }

    status_colors = {"confirmed" => "#FF6384", "pending" => "#36A2EB"}

    @data3 = {
      labels: ticket_names,
      datasets: Registration::STATUS.map do |s|
        {
          label: I18n.t(s, :scope => "registration.status"),
          data: @event.tickets.map {|t| t.registrations.by_status(s).count},
          backgroundColor: status_colors[s],
          borderWidth: 1
        }
      end
    }


    if @event.registrations.any?
      dates = (@event.registrations.order("id ASC").first.created_at.to_date..Date.today).to_a
      @data4 = {
        labels: dates,
        datasets: Registration::STATUS.map do |s|
          {
            label: I18n.t(s, :scope => "registration.status"),
            data: dates.map{ |d|
              @event.registrations.by_status(s).where("created_at >= ? AND created_at <= ?", d.beginning_of_day, d.end_of_day).count},
            backgroundColor: status_colors[s],
            borderWidth: 1
          }
        end
      }
    end
  end

  def new
    @event = Event.new
    @event.tickets.build
    @event.attachments.build
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to admin_events_path
    else
      render "new"
    end
  end

  def edit
    @event.tickets.build if @event.tickets.empty?
    @event.attachments.build if @event.attachments.empty?
  end

  def update


    if @event.update(event_params)
      redirect_to admin_events_path
    else
      render "edit"
    end
  end

  def destroy

    @event.destroy

    redirect_to admin_events_path
  end

  def bulk_update
    total = 0
    Array(params[:ids]).each do |event_id|
      event = Event.find(event_id)

      if params[:commit] == I18n.t(:bulk_update)
        event.status = params[:event_status]
        if event.save
          total += 1
        end
      elsif params[:commit] == I18n.t(:bulk_delete)
        event.destroy
        total += 1
      end
    end

    flash[:alert] = "成功完成#{total}笔"
    redirect_to admin_events_path
  end

  def reorder
    @event = Event.find_by_friendly_id!(params[:id])
    @event.row_order_position = params[:position]
    @event.save
    respond_to do |format|
      format.html {redirect_to admin_events_path}
      format.json {render :json => {:message => "ok"}}
    end
  end

  protected

  def find_the_event
    @event = Event.find_by_friendly_id!(params[:id])
  end


  def event_params
    params.require(:event).permit(:name, :description, :friendly_id, :status,:logo, :remove_logo, :category_id, :remove_images, :images => [],:tickets_attributes => [:id, :name, :description, :price,:_destroy], :attachments_attributes => [:id, :attachment, :description, :_destroy])
  end

end
