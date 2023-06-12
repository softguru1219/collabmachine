module MissionsHelper
  def interested?(mission)
    Applicant.where(mission_id: mission.id, user_id: current_user).any?
  end

  def link_to_mission(id)
    mission = Mission.find(id)
    link_to mission.title, mission
  end

  def terminate_step_button(mission, state)
    case state
    when 'draft'
      if policy(mission).show_submit_for_review_button?
        link_to t("status.draft.next_action"),
                { controller: :missions, action: :submit_mission_for_review, id: mission.id },
                { class: 'btn btn-outline btn-primary btn-xs', title: "If your mission is ready for production." }
      end

    when 'for_review'
      if policy(mission).show_mark_reviewed_button?
        link_to t("status.for_review.next_action"),
                { controller: :missions, action: :mark_mission_reviewed, id: mission.id },
                { class: 'btn btn-outline btn-primary btn-xs', title: "If this mission is ok." }
      end

    when 'reviewed'
      if policy(mission).show_open_for_candidate_button?
        link_to t("status.reviewed.next_action"),
                { controller: :missions, action: :open_mission_for_candidates, id: mission.id },
                { class: 'btn btn-outline btn-primary btn-xs', title: "Your mission is ready for prod." }
      end

    when 'assigned'
      if policy(mission).show_start_button?
        link_to t("status.assigned.next_action"),
                { controller: :missions, action: :start, id: mission.id },
                { class: 'btn btn-outline btn-primary btn-xs', title: "Ready, set...." }
      end

    when 'started'
      if policy(mission).show_mark_completed_button?
        link_to t("status.started.next_action"),
                { controller: :missions, action: :finish, id: mission.id },
                { class: 'btn btn-outline btn-primary btn-xs', title: "If your mission is ready for production." }
      end

    when 'finished'
      if policy(mission).show_reopen_button?
        link_to t("status.finished.next_action"),
                { controller: :missions, action: :reopen, id: mission.id },
                { class: 'btn btn-outline btn-primary btn-xs', title: "If your mission is ready for production." }
      end

      if policy(mission).show_send_invoice_button?
        if current_user.stripe_profile
          link_to t("status.finished.next_action"),
                  new_invoice_path(project: mission.project, mission: mission),
                  class: 'btn btn-outline btn-primary btn-xs', title: "If your mission is ready for production."
        else
          link_to t("status.finished.next_action"),
                  stripe_url,
                  class: 'btn btn-outline btn-primary btn-xs', title: "If your mission is ready for production."
        end
      end
    end
  end
end
