package hxng.widgets.friends.controllers;

@route({
  joinedTo: hxng.widgets.profile.Profile,
  url: '/friends',
  view: 'friends.html'
});
class Friends extends Controller {

}


class FriednsView extends View {
  function init() {

    Block('menu', 
      Dir('repeat', 'friends', 
        Item('friend', 
          Block('link', {
            url: '/profile/{{ friend.id }}',
            content: '{{ friend.name }}'
          })
        )
      )
    );

  }
}

@route({
  joinedTo: Friends,
  url: '/all',
  view: 'friends/list.html'
})
class All extends Friends {

}

@route({
  joinedTo: Friends,
  url: '/online'
})


@:directive({ selector: 'modal' })
class Modal<T> extends Directive {

  @:toWay('result')
  var result: Promise<T>;

  @:oneWayOneTime('shadow')
  var shadow: Bool;

  

}