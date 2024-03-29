﻿using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using reciWebApp.Data.IRepositories;
using reciWebApp.Data.Models;
using reciWebApp.Data.Pagination;
using reciWebApp.DTOs.PostDTOs;
using reciWebApp.DTOs.UserDTOs;
using reciWebApp.Services.Commons;
using reciWebApp.Services.Interfaces;
using reciWebApp.Services.Utils;

namespace reciWebApp.Controllers
{
    [Route("api/user")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly IRepositoryManager _repoManager;
        private readonly IServicesManager _servicesManager;
        private readonly IMapper _mapper;

        public UsersController(IRepositoryManager repoManager, IMapper mapper, IServicesManager servicesManager)
        {
            _repoManager = repoManager;
            _mapper = mapper;
            _servicesManager = servicesManager;
        }

        [HttpGet]
        [Route("~/api/user/page/{pageNumber}")]
        [RoleAuthorization(RoleTypes.Admin)]
        public async Task<IActionResult> Get(int pageNumber, [FromQuery] UserParams userParams)
        {
            try
            {
                var userList = await _repoManager.User.GetAllUserAsync(userParams);

                var showUserList = _mapper.Map<List<ShowUserDTO>>(userList);
                userParams.PageNumber = pageNumber;
                var result = PaginatedList<ShowUserDTO>.Create(showUserList, userParams.PageNumber, userParams.PageSize);
                return Ok(new Response(200, result, "", result.Meta));

                return Ok(new Response(200, showUserList));
            }
            catch (Exception e)
            {
                return BadRequest(new Response(400, e.Message));
            }

        }

        [HttpGet]
        [Route("~/api/user/{id}/allactivity")]
        [RoleAuthorization(RoleTypes.User, RoleTypes.Admin)]
        public async Task<IActionResult> Get(int id)
        {
            try
            {
                var user = await _repoManager.User.GetUserByIdAsync(id);
                if (user == null)
                {
                    return BadRequest(new Response(400, "User id does not existed"));
                }

                var bookmarks = await _repoManager.UserInteract.GetBookmarkAsync(id);
                var ratings = await _repoManager.UserInteract.GetRatingAsync(id);
                var posts = await _repoManager.Post.GetActivePostByUserIdAsync(id);
                var activity = _mapper.Map<ActivityDTO>(user);
                activity.TotalPosts = posts.Count;
                activity.TotalBookmarks = bookmarks.Count;
                activity.TotalRatings = ratings.Count;
                return Ok(new Response(200, activity));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }
    
    }
}
