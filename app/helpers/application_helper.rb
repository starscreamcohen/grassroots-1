module ApplicationHelper

  def skill_set(skills)
    skills.map(&:name)
  end

  def project_type_list
    ["Software Development", "Graphic Design", "Accounting", "Fundraising", "Business Consulting",
     "Marketing"].sort
  end

  def fix_date_time(dt)
    if logged_in? && !current_user.time_zone.blank?
      dt = dt.in_time_zone(current_user.time_zone)
    end
    dt.strftime("%m/%d/%Y")
  end

  def us_states
    [
      ['AK', 'AK'],
      ['AL', 'AL'],
      ['AR', 'AR'],
      ['AZ', 'AZ'],
      ['CA', 'CA'],
      ['CO', 'CO'],
      ['CT', 'CT'],
      ['DC', 'DC'],
      ['DE', 'DE'],
      ['FL', 'FL'],
      ['GA', 'GA'],
      ['HI', 'HI'],
      ['IA', 'IA'],
      ['ID', 'ID'],
      ['IL', 'IL'],
      ['IN', 'IN'],
      ['KS', 'KS'],
      ['KY', 'KY'],
      ['LA', 'LA'],
      ['MA', 'MA'],
      ['MD', 'MD'],
      ['ME', 'ME'],
      ['MI', 'MI'],
      ['MN', 'MN'],
      ['MO', 'MO'],
      ['MS', 'MS'],
      ['MT', 'MT'],
      ['NC', 'NC'],
      ['ND', 'ND'],
      ['NE', 'NE'],
      ['NH', 'NH'],
      ['NJ', 'NJ'],
      ['NM', 'NM'],
      ['NV', 'NV'],
      ['NY', 'NY'],
      ['OH', 'OH'],
      ['OK', 'OK'],
      ['OR', 'OR'],
      ['PA', 'PA'],
      ['RI', 'RI'],
      ['SC', 'SC'],
      ['SD', 'SD'],
      ['TN', 'TN'],
      ['TX', 'TX'],
      ['UT', 'UT'],
      ['VA', 'VA'],
      ['VT', 'VT'],
      ['WA', 'WA'],
      ['WI', 'WI'],
      ['WV', 'WV'],
      ['WY', 'WY']
    ]
  end

  def project_title(project)
    if project.title > project.title.first(25)
      "#{project.title.first(25)}..."
    else
      "#{project.title}"
    end
  end

  def current_user_contractor(conversation)
    contract = Contract.find(conversation.contract_id)
    contractor = User.find(contract.contractor_id)
    current_user == contractor
  end

  def current_user_project_administrator?(project)
    project.project_admin == current_user
  end

  def current_user_staff_of_organizations?(project)
    project.organization == current_user.organization
  end

  def current_user_a_volunteer?(project)
    current_user != project.project_admin || current_user.organization != project.organization
  end
end
