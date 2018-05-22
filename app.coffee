# Configure viewport
Framer.Device.customize
	deviceType: "fullscreen"
	screenWidth: 1700
	screenHeight: 956
	deviceImageWidth: 1700
	deviceImageHeight: 956
	devicePixelRatio: 1

slicesOpen = false
pageTransitioning = false
	
# Home page
home.x = 0
home.y = 0

homeItems = [homeNavbar, homeHeadline_1, homeHeadline_2, homeHeadline_3, homeThumbnail_1, homeThumbnail_2]

homeContents.states =
	initial:
		skewX: 0
		opacity: 1
		x: Align.left
	skewLeft:
		skewX: 30 
		x: Align.left(-1000)
		opacity: 0
		
homeContents.originX = .5
homeContents.originY = .5

# Navbar
homeNavbar.states =
	hidden:
		y: Align.center(-100)
	visible:
		y: Align.center
		
# Headlines
for headline, i in [homeHeadline_1, homeHeadline_2, homeHeadline_3]
	headline.states =
		initial:
			x: Align.left
		outLeft:
			x: Align.left(-500)

# Thumbnails
for thumbnail, i in [homeThumbnail_1, homeThumbnail_2]
	thumbnail.states =
		initial:
			x: Align.left
		outLeft:
			x: Align.left(-500)
		
		
homeAnimateOut = () ->
	homeContents.animate 'skewLeft'
	
showHome = () ->
	home.bringToFront()
	homeContents.stateSwitch 'initial'
	
homeReset = () ->
	homeContents.stateSwitch 'initial'

# Project page
project.x = 0
project.y = 0

project.states =
	visible:
		opacity: 1
	hidden:
		opacity: 0
		
project.stateSwitch 'hidden'

showProject = () ->
	project.bringToFront()
	project.stateSwitch 'visible'
	
hideProject = () ->
	project.sendToBack()
	project.stateSwitch 'hidden'

# Slice Animation

shuffleArray = (source) ->
  # Arrays with < 2 elements do not shuffle well. Instead make it a noop.
  return source unless source.length >= 2
  # From the end of the list to the beginning, pick element `index`.
  for index in [source.length-1..1]
    # Choose random element `randomIndex` to the front of `index` to swap with.
    randomIndex = Math.floor Math.random() * (index + 1)
    # Swap `randomIndex` with `index`, using destructured assignment
    [source[index], source[randomIndex]] = [source[randomIndex], source[index]]
  source
  
# Overlay
overlay = new Layer
	width: page.width
	height: page.height
	x: 0
	y: 0
	backgroundColor: '#1B1C26'
	
overlay.states =
	hidden:
		opacity: 0
	visible:
		opacity: 1
		
canvas.addChild(overlay)

overlay.stateSwitch 'hidden'

# Slices setup
sliceArray = [0..5]
sliceInnerArray = []
sliceElArray = []

# Create slices
for i in sliceArray
	sliceHeight = Math.round(page.height / sliceArray.length)
	
	slice = new Layer
		y: sliceHeight * i
		x: 0
		height: sliceHeight + 2
		width: page.width
		backgroundColor: 'transparent'
		borderWidth: 0
	
	slice.clip = true
	
	sliceInner = new Layer
		height: slice.height
		width: slice.width
		
	sliceInner.states =
		right:
			x: slice.width
		left:
			x: -slice.width
		show:
			x: 0
		
	slice.addChild(sliceInner)
	
	canvas.addChild(slice)
	
	sliceInner.x = 0
	sliceInner.y = Align.center
	
	sliceInnerArray.push sliceInner
	sliceInner.stateSwitch 'right'
	
	sliceElArray.push slice

# Rotates the slice
rotateSlice = (item, slideTime, dir) ->
	skewAmount = if dir is 'left' then 30 else -30
	
	item.originY = 1
	
	if dir is 'left'
		item.originX = 0
		
	else if dir is 'right'
		item.originX = 1
	
	item.animate
		skewX: skewAmount
		animationOptions =
			time: slideTime / 2
	
	Utils.delay slideTime / 2, ->
		item.animate
			skewX: 0
			animationOptions =
				time: slideTime / 2

# Slice animations
# Uses random shuffle to randomize delay and timing for each slice
animateSlices = (dir, state, contrast, cb) ->
	pageTransitioning = true

# 	Bring all slices to the front above shuffled page content
	for slice, i in sliceElArray
		slice.bringToFront()
		
	shuffledOrder = shuffleArray(sliceArray)
	
	if state is 'show'
		overlay.animate 'visible'
	else if state is 'hide'
		overlay.animate 'hidden'
	
	for itemIndex, i in shuffledOrder
		item = sliceInnerArray[itemIndex]
		
		if contrast is 'dark'
			item.backgroundColor = '#1B1C26'
		else
			item.backgroundColor = '#FBFCFC'
		
		slideTime = i / 10 + .3
		kickoffDelay = i / 20
		
		animationOpts =
			time: slideTime
			delay: kickoffDelay
		
		rotateSlice(item, slideTime, dir)
		
		if state is 'hide'
			item.stateSwitch 'show'
			
			if dir is 'left'
				item.animate 'left',
					animationOptions = animationOpts
			else if dir is 'right'
				item.animate 'right',
					animationOptions = animationOpts
		
		if state is 'show'
			if dir is 'left'
				item.stateSwitch 'right'
			else if dir is 'right'
				item.stateSwitch 'left'
			
			item.animate 'show',
				animationOptions = animationOpts
		
# 		This is hacky and brittle but quick for now
		do (i) ->
			if i == (shuffledOrder.length - 1) and cb
				Utils.delay slideTime + kickoffDelay, ->
					print 'hello'
					pageTransitioning = false
					cb()
				
# 				item.on Events.AnimationEnd, ->
# 					item.on Events.AnimationEnd, ->
# 						item.off Events.AnimationEnd
# 						pageTransitioning = false
# 						cb()



testButton.on Events.MouseDown, ->
	if pageTransitioning
		return

	if !slicesOpen
		slicesOpen = true
		
		animateSlices('left', 'show', 'light', showProject)
		homeAnimateOut()
		
	else if slicesOpen
		slicesOpen = false
		
		animateSlices('right', 'show', 'dark', () ->
			hideProject()
			showHome()
		)
		
		homeReset()
		