class ProfilesController < ApplicationController
   def index
    @user = User.find(1)
    raise Forbidden unless tuned_test_user_safe?

    @skill_categories = tuned_user_reccomend_skill_categories
    @articles = @user.articles.preload(:tags)
  end

  private

  def user_safe?
    @user.user_cautions.all? do |user_caution|
      Time.zone.now > user_caution.caution_freeze.end_time
    end
  end

  def user_reccomend_skill_categories
    @user.skills.map(&:skill_category).
      filter { |skill_category| skill_category.reccomend }.uniq
  end

  def test
    reset_queries
    @user.skills.map(&:skill_category).
      filter { |skill_category| skill_category.reccomend }.uniq
    show_queries
  end

  def tuned_user_reccomend_skill_categories
    SkillCategory.where(reccomend: true).eager_load(:skills).where(skills: { user_id: @user.id })
  end

  def test
    reset_queries
    User.find(1).articles.each do |article|
      article.tags.each do |tag|
        tag.name
      end
    end
    show_queries
  end

  def test_preload
    reset_queries
    User.find(1).articles.preload(:tags).each do |article|
      article.tags.each do |tag|
        tag.name
      end
    end
    show_queries
  end

  def test_user_safe?
    reset_queries
    @user.user_cautions.all? do |user_caution|
      Time.zone.now > user_caution.caution_freeze.end_time
    end
    show_queries
  end

  def tuned_test_user_safe?
    # reset_queries
    @user.user_cautions.joins(:caution_freeze).
      where('caution_freezes.end_time > ?', Time.zone.now).empty?
    # show_queries
  end
end