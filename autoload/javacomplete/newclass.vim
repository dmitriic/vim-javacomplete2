" Vim completion script for java
" Maintainer: artur shaik <ashaihullin@gmail.com>
"
" Classes generator

function! s:Log(log)
  let log = type(a:log) == type("") ? a:log : string(a:log)
  call javacomplete#logger#Log("[generators] ". log)
endfunction

function! javacomplete#newclass#CreateClass()
  let message = "enter new class name: "
  let userinput = input(message, '')
  if empty(userinput)
    return
  endif
  let currentPackage = split(javacomplete#collector#GetPackageName(), '\.')
  let path = split(userinput, '\.')
  let currentPath = expand('%:p')
  let currentPathList = split(currentPath, g:FILE_SEP)[:-2]
  let data = s:ParseInput(
        \ path, reverse(copy(currentPathList)), currentPackage)
  let data['current_path'] = '/'. join(currentPathList, g:FILE_SEP). '/'
  call s:CreateClass(data)
endfunction

function! s:CreateClass(data)
  let path = a:data['current_path']
        \ . g:FILE_SEP
        \ . a:data['path']
  if filewritable(path) != 2
    call mkdir(path, 'p')
  endif
  let fileName = fnamemodify(path. g:FILE_SEP. a:data['class'], ":p")
  execute ':e '. fileName. '.java'
  if filewritable(fileName. '.java') == 0
    call append(0, 'package '. a:data['package']. ';')
    call append(line('$'), 'public class '. a:data['class']. ' {')
    call append(line('$'), '')
    call append(line('$'), '}')
    call cursor(4, 1)
  endif
endfunction

function! s:ParseInput(path, currentPath, currentPackage)
  if len(a:path) == 1
    return {
          \ 'path' : '', 
          \ 'class' : a:path[0], 
          \ 'package' : join(a:currentPackage, '.')
          \ }
  elseif a:path[0] == '/' || a:path[0][0] == '/'
    if a:path[0] == '/'
      let path = a:path[1:]
    else
      let path = a:path
      let path[0] = path[0][1:]
    endif
    let idx = index(a:currentPath, a:currentPackage[0])
    let currentPath = idx >= 0 ? a:currentPath[:idx] : a:currentPath
    let i = len(path) - 2
    let newPath = ""
    let newPackage = []
    let idx = index(currentPath, path[i])
    while i > 0
      let newPath .= '..'. g:FILE_SEP
      call add(newPackage, path[i])
      let i -= 1
      let idx = index(currentPath, path[i])
    endwhile
    if idx < 0
      let newPath = repeat('..'. g:FILE_SEP, len(currentPath))
      let newPackage = path[:-2]
      if i == 0
        let i = -1
      endif
    else
      call extend(reverse(newPackage), reverse(currentPath)[:-idx - 1], 0)
    endif
    let newPath = newPath. join(path[i+1:-2], g:FILE_SEP)
    return {
          \ 'path' : newPath, 
          \ 'class' : path[-1], 
          \ 'package' : join(newPackage, '.')
          \ }
  else
    let newPackage = join(a:currentPackage, '.'). '.'. join(a:path[:-2], '.')
    return {
          \ 'path' : join(a:path[:-2], g:FILE_SEP), 
          \ 'class' : a:path[-1], 
          \ 'package' : newPackage
          \ }
  endif
endfunction

" vim:set fdm=marker sw=2 nowrap:
