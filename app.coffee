# Configure viewport
Framer.Device.customize
	deviceType: "fullscreen"
	screenWidth: 1700
	screenHeight: 956
	deviceImageWidth: 1700
	deviceImageHeight: 956
	devicePixelRatio: 1
	
holder.x = 0
holder.y = 0
page.x = 0
page.y = 0

page.states =
	light:
		backgroundColor: '#FBFCFC'
	dark:
		backgroundColor: '#1B1C26'

slicesOpen = false
pageTransitioning = false
		
# Slice Animation

# Shuffle helper
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

# Slices setup
sliceArray = [0..5]
sliceInnerArray = []
sliceElArray = []
sliceCurve = Bezier(.16,.26,.04,.98)

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
		animationOptions:
			curve: sliceCurve
	
	sliceInner = new Layer
		height: slice.height
		width: slice.width
		animationOptions:
			curve: sliceCurve
		
	slice.states =
		right:
			x: slice.width
		left:
			x: -slice.width
		peek:
			x: 2000
		show:
			x: 0
	
	slice.stateSwitch 'right'
		
	slice.addChild(sliceInner)
	
	canvas.addChild(slice)
	
	sliceInner.x = 0
	sliceInner.y = Align.center
	
	sliceInnerArray.push sliceInner
	
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

hideSlices = () ->
	for slice, i in sliceElArray
		slice.stateSwitch 'right'
		


generateTimings = (array) ->
	timings = []
	
	for itemIndex, i in shuffleArray(array)
		set = {
			itemIndex: itemIndex
			slideTime: i / 10 + .2
			kickoffDelay: i / 30
		}
		
		timings.push(set)
	
	return timings


animateSlices = (opts) ->
	{ dir, state, contrast, cb } = opts;
	
	pageTransitioning = true

# 	Bring all slices to the front above shuffled page content
	for slice, i in sliceElArray
		slice.bringToFront()
		
	sliceTimings = generateTimings(sliceArray)
	
	for set, i in sliceTimings
		itemOuter = sliceElArray[set.itemIndex]
		itemInner = sliceInnerArray[set.itemIndex]
		
		if contrast is 'dark'
			itemInner.backgroundColor = '#1B1C26'
		else
			itemInner.backgroundColor = '#FBFCFC'
		
		slideTime = set.slideTime
		kickoffDelay = set.kickoffDelay
		
		animationOpts =
			time: slideTime
			delay: kickoffDelay
		
		rotateSlice(itemInner, slideTime, dir)
		
		if state is 'hide'
			itemOuter.stateSwitch 'show'
			
			if dir is 'left'
				itemOuter.animate 'left',
					animationOptions = animationOpts
			else if dir is 'right'
				itemOuter.animate 'right',
					animationOptions = animationOpts
		
		if state is 'show'
			if dir is 'left'
				itemOuter.stateSwitch 'right'
			else if dir is 'right'
				itemOuter.stateSwitch 'left'
			
			itemOuter.animate 'show',
				animationOptions = animationOpts
				
		
# 		Run callback after last slice has completed animation
		do (i) ->
			if i == (sliceTimings.length - 1)
				pageTransitioning = false
				
				Utils.delay slideTime + kickoffDelay, ->
					if cb
						cb()
	
# Home page
home.x = 0
home.y = 0

homeHeadlines = [homeHeadline_1, homeHeadline_2, homeHeadline_3]
homeThumbnails = [homeThumbnail_1, homeThumbnail_2]
yearNumbers = [year_1, year_2, year_3, year_4]

homeContents.states =
	initial:
		skewX: 0
		opacity: 1
		x: Align.left
	skewLeft:
		skewX: 30 
		x: Align.left(-1000)
		opacity: 0
		animationOptions:
			time: .5
		
homeContents.originX = .5
homeContents.originY = .5

# Gradient
homeGradient.states =
	visible:
		opacity: 1;
	hidden:
		opacity: 0;

homeShowGradient = () ->
	homeGradient.stateSwitch 'hidden'
	homeGradient.animate 'visible'

# Navbar
homeNavbar.states =
	hidden:
		y: Align.center(-50)
		opacity: 0
	visible:
		y: Align.center
		opacity: 1
		animationOptions:
			time: .3
		
homeShowNavbar = () ->
	homeNavbar.stateSwitch 'hidden'
	homeNavbar.animate 'visible'
		
# Headlines
for headline, i in homeHeadlines
	headline.states =
		initial:
			x: Align.left
			y: Align.top
			opacity: 1
			animationOptions:
				time: .5
				delay: i / 20 + .1
		outBottom:
			x: Align.left
			y: Align.top(100)
			opacity: 0

homeShowHeadlines = () ->
	for headline, i in homeHeadlines
		headline.stateSwitch 'outBottom'
		headline.animate 'initial'

# Thumbnails
for thumbnail, i in homeThumbnails
	thumbnail.states =
		initial:
			x: Align.left
			y: Align.top
			opacity: 1
			animationOptions:
				time: .7
				delay: i / 20
		outBottom:
			x: Align.left
			y: Align.top(500)
			opacity: 0

homeShowThumbnails = () ->
	for thumbnail, i in homeThumbnails
		thumbnail.stateSwitch 'outBottom'
		thumbnail.animate 'initial'

# Numbers
for number, i in yearNumbers
	number.states =
		initial:
			y: Align.top
			opacity: 1
			animationOptions:
				time: .7
				delay: .1
		outBottom:
			y: Align.top(200)
			opacity: 0
			

homeShowNumbers = () ->
	for number, i in yearNumbers
		number.stateSwitch 'outBottom'
		number.animate 'initial'
		
homeAnimateOut = () ->
	homeContents.animate 'skewLeft'
	
showHome = () ->
	home.bringToFront()
	homeContents.stateSwitch 'initial'
	
	homeShowGradient()
	homeShowNavbar()
	homeShowHeadlines()
	homeShowThumbnails()
	homeShowNumbers()
	
testBtn.on Events.MouseDown, ->
	showHome()

# Project page
project.x = 0
project.y = 0

# Page
project.states =
	visible:
		opacity: 1
	hidden:
		opacity: 0
		
project.stateSwitch 'hidden'

# Contents
projectContents.states =
	initial:
		skewX: 0
		opacity: 1
		x: Align.left
	skewLeft:
		skewX: 30 
		x: Align.left(-1000)
		opacity: 0
		animationOptions:
			time: .5
	skewRight:
		skewX: -30 
		x: Align.right(1000)
		opacity: 0
		animationOptions:
			time: .5

# Navbar
projectNavBar.states =
	visible:
		x: Align.left
		y: Align.top
		opacity: 1
	hiddenAbove:
		y: Align.top(-100)
		opacity: 0
		
# Pagination bar
paginationBar.states =
	visible:
		y: Align.top
		animationOptions:
			delay: .3
	hidden:
		y: paginationBar.height
	

# Headline
projectHeadline.states =
	visible:
		x: Align.left
		y: Align.top
		opacity: 1
	hiddenBelow:
		y: Align.top(100)
		opacity: 0

# Desc
projectDesc.states =
	visible:
		x: Align.left
		y: Align.top
		opacity: 1
	hiddenBelow:
		y: Align.top(100)
		opacity: 0

# Image
projectImage.states =
	visible:
		x: Align.left
		y: Align.top
		opacity: 1
	hiddenBelow:
		y: Align.top(100)
		opacity: 0
	
hideProjectRight = () ->
	projectContents.animate 'skewRight'

showProjectRight = () ->
	projectContents.stateSwitch 'skewLeft'
	projectContents.animate 'initial'

hideProjectLeft = () ->
	projectContents.animate 'skewLeft'
	
showProjectLeft = () ->
	projectContents.stateSwitch 'skewRight'
	projectContents.animate 'initial'
	
projectReset = () ->
	project.sendToBack()
	project.stateSwitch 'hidden'
	projectContents.stateSwitch 'initial'
	projectNavBar.stateSwitch 'hiddenAbove'
	projectHeadline.stateSwitch 'hiddenBelow'
	projectDesc.stateSwitch 'hiddenBelow'
	projectImage.stateSwitch 'hiddenBelow'
	paginationBar.stateSwitch 'hidden'
	
showProject = () ->
	project.bringToFront()
	page.stateSwitch 'light'
	page.placeBehind(project)
	
animateProject = () ->
	showProject()

	project.stateSwitch 'visible'
	projectNavBar.animate 'visible'
	projectHeadline.animate 'visible'
	projectDesc.animate 'visible'
	projectImage.animate 'visible'
	paginationBar.animate 'visible'


loadFirstProjectButton.on Events.MouseDown, ->
	if pageTransitioning
		return
		
	projectReset()
		
	animateSlices(
		dir: 'left'
		state: 'show'
		contrast: 'light'
		cb: () -> 
			animateProject()
			hideSlices()
	)

	homeAnimateOut()

backToHomeButton.on Events.MouseDown, ->
	if pageTransitioning
		return
		
	hideProjectRight()
		
	animateSlices(
		dir: 'right'
		state: 'show'
		contrast: 'dark'
		cb: () ->
			projectReset()
			showHome()
			hideSlices()
	)
	
# backToHomeButton.on Events.MouseOver, ->
# 	animateSlices(
# 		dir: 'peek'
# 		state: 'show'
# 		contrast: 'dark'
# 	)
	

prevProject.on Events.MouseDown, ->
	if pageTransitioning
		return
	
	hideProjectRight()
		
	animateSlices(
		dir: 'right'
		state: 'show'
		contrast: 'dark'
		cb: () ->
			projectReset()
			showProject()
			animateSlices(
				dir: 'right'
				state: 'hide'
				contrast: 'dark'
				cb: animateProject
			)
	)

nextProject.on Events.MouseDown, ->
	if pageTransitioning
		return
	
	hideProjectLeft()
		
	animateSlices(
		dir: 'left'
		state: 'show'
		contrast: 'dark'
		cb: () ->
			projectReset()
			animateProject()
			animateSlices(
				dir: 'left'
				state: 'hide'
				contrast: 'dark'
			)
	)
