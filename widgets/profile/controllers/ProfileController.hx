package hxng.profile.controllers;

class ProfileController extends Controller {

  public function configure() {
    // inject services here
  }


  @:view('profiles.html')
  public function init(scope:Dynamic) {

    scope.close = function (id) {
      // @TODO: Remove profile from opened profiles list
    }

  }

  @:route('profile', '/:id', true)
  @:view('profile.html')
  public function profileAction(scope:Dynamic) {
    var id = this.router.get('id');
    // @TODO: Add profile to opened profiles list, mark as active

  }

  @:route('profile.info', '/')
  @:view('profile/info.html')
  public function infoAction(scope:Dynamic) {

  }

  @:route('profile.settings', '/settings', true)
  @:view('profile/settings.html')
  public function settingsAction(scope:Dynamic) {

  }

  @:route('profile.settings.common', '/')
  @:view('profile/settings/common.html')
  public function settingsCommonAction(scope:Dynamic) {

  }

  @:route('profile.settings.merge', '/merge/')
  @:view('profile/settings/merge.html')
  public function settingsMergeAction(scope:Dynamic) {

  }

}