﻿using AutoMapper;
using Google.Apis.Util;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Hosting;
using Newtonsoft.Json.Linq;
using reciWebApp.Data.IRepositories;
using reciWebApp.Data.Models;
using reciWebApp.Data.Pagination;
using reciWebApp.DTOs.PostDTOs;
using reciWebApp.Services.Commons;
using reciWebApp.Services.Interfaces;
using reciWebApp.Services.Utils;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace reciWebApp.Controllers
{
    [Route("api/post")]
    [ApiController]
    public class PostsController : ControllerBase
    {
        private readonly IRepositoryManager _repoManager;
        private readonly IServicesManager _servicesManager;
        private readonly IMapper _mapper;

        public PostsController(IRepositoryManager repoManager, IMapper mapper, IServicesManager servicesManager)
        {
            _repoManager = repoManager;
            _mapper = mapper;
            _servicesManager = servicesManager;
        }

        //Get recipe detail
        [HttpGet("{id}")]
        [RoleAuthorization(RoleTypes.Admin, RoleTypes.User)]
        public async Task<IActionResult> Get(string id)
        {
            try
            {
                var currentUser = await _servicesManager.AuthService.GetUser(Request);

                if (currentUser == null)
                {
                    return BadRequest(new Response(400, "Invalid user"));
                }

                var post = await _repoManager.Post.GetActivePostByIdAsync(id);

                if (post == null)
                {
                    return BadRequest(new Response(400, "Post id does not existed"));
                }

                var showPost = _mapper.Map<ShowPostDTO>(post);
                showPost = await _servicesManager.PostService.GetPostInfo(showPost);
                var showDetailPost = _mapper.Map<ShowDetailPostDTO>(showPost);
                showDetailPost.Bookmark = _repoManager.UserInteract.CheckBookMark(currentUser.Id, id);
                showDetailPost.Rating = _repoManager.UserInteract.GetRating(currentUser.Id, id);
                showDetailPost.IsReport = _repoManager.PostReport.CheckReport(currentUser.Id, id);
                return Ok(new Response(200, showDetailPost));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }

        //View list my recipes
        [Route("~/api/user/{id}/post/page/{pageNumber}")]
        [RoleAuthorization(RoleTypes.User, RoleTypes.Admin)]
        [HttpGet]
        public async Task<IActionResult> Get(int id, int pageNumber, [FromQuery] MyPostParams myPostParams)
        {
            try
            {
                var posts = await _repoManager.Post.GetAllPostsByUserIdAsync(myPostParams.Search, id);

                myPostParams.PageNumber = pageNumber;
                var showPosts = _mapper.Map<List<ShowPostDTO>>(posts);
                for (int i = 0; i < showPosts.Count; i++)
                {
                    showPosts[i] = await _servicesManager.PostService.GetPostInfo(showPosts[i]);
                }

                if (myPostParams.Sort != null)
                {
                    showPosts = _repoManager.Post.SortPostByCondition(showPosts, myPostParams.Sort);
                }

                var result = PaginatedList<ShowPostDTO>.Create(showPosts, myPostParams.PageNumber, myPostParams.PageSize);
                return Ok(new Response(200, result, "", result.Meta));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }

        //Create recipe
        [Route("~/api/user/{id}/post")]
        [RoleAuthorization(RoleTypes.User)]
        [HttpPost]
        public async Task<IActionResult> Post(int id, [FromBody] CreatePostDTO postDTO)
        {
            try
            {
                var user = await _repoManager.User.GetUserByIdAsync(id);

                if (user == null)
                {
                    return BadRequest(new Response(400, "User id does not existed"));
                }

                var createPost = _mapper.Map<Post>(postDTO);
                createPost.UserId = id;
                createPost.Id = DateTime.Now.ToString("yyyyMMddHHmmssffff");
                _repoManager.Post.CreatePost(createPost);
                await _repoManager.SaveChangesAsync();
                var createStep = _mapper.Map<Step>(postDTO);
                createStep.PostsId = createPost.Id;
                _repoManager.Step.CreateStep(createStep);
                await _repoManager.SaveChangesAsync();
                foreach (var categoryId in postDTO.CategoriesId)
                {
                    var postCategory = new PostCategory
                    {
                        PostId = createPost.Id,
                        CategoryId = categoryId
                    };
                    _repoManager.PostCategory.CreatePostCategory(postCategory);
                }
                await _repoManager.SaveChangesAsync();
                return Ok(new Response(200, createPost.Id, "Create successfully"));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }

        //Update recipe
        [HttpPut("{id}")]
        [RoleAuthorization(RoleTypes.User)]
        public async Task<IActionResult> Put(string id, [FromBody] UpdatePostDTO updatePostDTO)
        {
            try
            {
                var currentUser = await _servicesManager.AuthService.GetUser(Request);

                if (currentUser == null)
                {
                    return BadRequest(new Response(400, "Invalid user"));
                }

                var post = await _repoManager.Post.GetActivePostByIdAsync(id);
                if (post == null)
                {
                    return BadRequest(new Response(400, "Invalid post id"));
                }

                if (!_servicesManager.PostService.CheckPostAuthority(currentUser.Id, id))
                {
                    return BadRequest(new Response(400, "You do not have permission"));
                }

                _mapper.Map(updatePostDTO, post);
                _repoManager.Post.UpdatePost(post);

                var step = await _repoManager.Step.GetStepByPostIdAsync(id);
                _mapper.Map(updatePostDTO, step);
                _repoManager.Step.UpdateStep(step);

                _repoManager.PostCategory.RemovePostCategory(id);

                foreach (var categoryId in updatePostDTO.CategoriesId)
                {
                    var postCategory = new PostCategory
                    {
                        PostId = id,
                        CategoryId = categoryId
                    };
                    _repoManager.PostCategory.CreatePostCategory(postCategory);
                }

                await _repoManager.SaveChangesAsync();
                return Ok(new Response(200, "", "Update successfully"));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }

        //Delete Recipe
        [HttpDelete("{id}")]
        [RoleAuthorization(RoleTypes.User)]
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                var currentUser = await _servicesManager.AuthService.GetUser(Request);

                if (currentUser == null)
                {
                    return BadRequest(new Response(400, "Invalid user"));
                }

                var post = await _repoManager.Post.GetActivePostByIdAsync(id);
                if (post == null)
                {
                    return BadRequest(new Response(400, "Invalid post id"));
                }

                if (!_servicesManager.PostService.CheckPostAuthority(currentUser.Id, id))
                {
                    return BadRequest(new Response(400, "You do not have permission"));
                }

                _repoManager.Post.DeletePost(post);
                await _repoManager.SaveChangesAsync();

                return Ok(new Response(200, "Delete successfully"));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }

        //Get my bookmark recipes
        [HttpGet("bookmark/page/{pageNumber}")]
        [RoleAuthorization(RoleTypes.User)]
        public async Task<IActionResult> Get(int pageNumber, [FromQuery] BookmarkParams bookmarkParams)
        {
            try
            {
                var currentUser = await _servicesManager.AuthService.GetUser(Request);

                if (currentUser == null)
                {
                    return BadRequest(new Response(400, "Invalid user"));
                }

                var bookmarks = await _repoManager.UserInteract.GetBookmarkAsync(currentUser.Id);

                var posts = await _repoManager.Post.GetPostByUserInteractsAsync(bookmarks, bookmarkParams.Search);
                var showPosts = _mapper.Map<List<ShowPostDTO>>(posts);
                for (int i = 0; i < showPosts.Count; i++)
                {
                    showPosts[i] = await _servicesManager.PostService.GetPostInfo(showPosts[i]);
                }

                if (bookmarkParams.Sort != null)
                {
                    showPosts = _repoManager.Post.SortPostByCondition(showPosts, bookmarkParams.Sort);
                }

                bookmarkParams.PageNumber = pageNumber;
                var result = PaginatedList<ShowPostDTO>.Create(showPosts, bookmarkParams.PageNumber, bookmarkParams.PageSize);
                return Ok(new Response(200, result, "", result.Meta));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }

        //Get my rating recipes
        [HttpGet("rating/page/{pageNumber}")]
        [RoleAuthorization(RoleTypes.User)]
        public async Task<IActionResult> Get(int pageNumber, int userId, [FromQuery] RatingParams ratingParams)
        {
            try
            {
                var currentUser = await _servicesManager.AuthService.GetUser(Request);

                if (currentUser == null)
                {
                    return BadRequest(new Response(400, "Invalid user"));
                }

                var ratings = await _repoManager.UserInteract.GetRatingAsync(currentUser.Id);

                ratingParams.PageNumber = pageNumber;
                var posts = await _repoManager.Post.GetPostByUserInteractsAsync(ratings, ratingParams.Search);
                var showPosts = _mapper.Map<List<ShowPostDTO>>(posts);
                for (int i = 0; i < showPosts.Count; i++)
                {
                    showPosts[i] = await _servicesManager.PostService.GetPostInfo(showPosts[i]);
                }

                if (ratingParams.Sort != null)
                {
                    showPosts = _repoManager.Post.SortPostByCondition(showPosts, ratingParams.Sort);
                }

                var result = PaginatedList<ShowPostDTO>.Create(showPosts, ratingParams.PageNumber, ratingParams.PageSize);
                return Ok(new Response(200, result, "", result.Meta));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }

        //Get all recipes by method
        [HttpGet]
        [Route("~/api/method/post/page/{pageNumber}")]
        public async Task<IActionResult> Get(int pageNumber, [FromQuery] FilterByMethodParams filter)
        {
            try
            {
                List<Post>? getPostsByCookingMethods = null;
                if (filter.Method != null)
                {
                    var cookingMethods = _repoManager.CookingMethod.GetCookingMethodsByName(filter.Method);
                    getPostsByCookingMethods = _repoManager.Post.GetPostsByCookingMethods(cookingMethods.Select(x => x.Id).ToList());
                }

                var postParams = new PostParams
                {
                    Name = filter.Search,
                    PostsByCookingMethods = getPostsByCookingMethods,
                    PageNumber = filter.PageNumber,
                    PageSize = filter.PageSize,
                    Type = filter.Sort,
                };
                postParams.PageNumber = pageNumber;
                var posts = await _repoManager.Post.GetPostsFilterByMethodsAsync(postParams);
                var showPosts = _mapper.Map<List<ShowPostDTO>>(posts);
                for (int i = 0; i < showPosts.Count; i++)
                {
                    showPosts[i] = await _servicesManager.PostService.GetPostInfo(showPosts[i]);
                }

                if (postParams.Type != null)
                {
                    showPosts = _repoManager.Post.SortPostByCondition(showPosts, postParams.Type);
                }

                var result = PaginatedList<ShowPostDTO>.Create(showPosts, postParams.PageNumber, postParams.PageSize);
                return Ok(new Response(200, result, "", result.Meta));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }

        //Get all recipes by category
        [HttpGet]
        [Route("~/api/category/post/page/{pageNumber}")]
        public async Task<IActionResult> Get(int pageNumber, [FromQuery] FilterByCategoryParams filter)
        {
            try
            {
                List<Post>? getPostsByCategories = null;
                if (filter.Category != null)
                {
                    var categories = _repoManager.Category.GetCategoryByName(filter.Category);
                    var postCategories = _repoManager.PostCategory.GetPostCategoriesByCategory(categories);
                    getPostsByCategories = _repoManager.Post.GetPostsByPostCategories(postCategories);
                }

                var postParams = new PostParams
                {
                    Name = filter.Search,
                    PostsByCategories = getPostsByCategories,
                    PageNumber = filter.PageNumber,
                    PageSize = filter.PageSize,
                    Type = filter.Sort,
                };
                postParams.PageNumber = pageNumber;
                var posts = await _repoManager.Post.GetPostsFilterByCategoriesAsync(postParams);
                var showPosts = _mapper.Map<List<ShowPostDTO>>(posts);
                for (int i = 0; i < showPosts.Count; i++)
                {
                    showPosts[i] = await _servicesManager.PostService.GetPostInfo(showPosts[i]);
                }

                if (postParams.Type != null)
                {
                    showPosts = _repoManager.Post.SortPostByCondition(showPosts, postParams.Type);
                }

                var result = PaginatedList<ShowPostDTO>.Create(showPosts, postParams.PageNumber, postParams.PageSize);
                return Ok(new Response(200, result, "", result.Meta));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }

        //Get all recipes by use and region
        [HttpGet]
        [Route("~/api/recipes/post/page/{pageNumber}")]
        public async Task<IActionResult> Get(int pageNumber, [FromQuery] FilterByUsesAndRegionsParams filter)
        {
            try
            {
                List<Post>? getPostsByRecipeRegions = null;
                if (filter.Continent != null)
                {
                    var recipeRegions = _repoManager.RecipeRegion.GetRecipeRegionsByName(filter.Continent);
                    getPostsByRecipeRegions = _repoManager.Post.GetPostsByRecipeRegions(recipeRegions);
                }

                List<Post>? getPostsByUses = null;
                if (filter.Uses != null)
                {
                    var uses = _repoManager.Use.GetUsesByName(filter.Uses);
                    getPostsByUses = _repoManager.Post.GetPostsByUses(uses);
                }

                var postParams = new PostParams
                {
                    Name = filter.Search,
                    PostsRecipeRegions = getPostsByRecipeRegions,
                    PostsByUses = getPostsByUses,
                    PageNumber = filter.PageNumber,
                    PageSize = filter.PageSize,
                    Type = filter.Sort,
                };
                postParams.PageNumber = pageNumber;
                var posts = await _repoManager.Post.GetPostsFilterByUsesAndRegionsAsync(postParams);
                var showPosts = _mapper.Map<List<ShowPostDTO>>(posts);
                for (int i = 0; i < showPosts.Count; i++)
                {
                    showPosts[i] = await _servicesManager.PostService.GetPostInfo(showPosts[i]);
                }

                if (postParams.Type != null)
                {
                    showPosts = _repoManager.Post.SortPostByCondition(showPosts, postParams.Type);
                }

                var result = PaginatedList<ShowPostDTO>.Create(showPosts, postParams.PageNumber, postParams.PageSize);
                return Ok(new Response(200, result, "", result.Meta));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }

        //Get collections recipe
        [HttpGet]
        [Route("~/api/collections/post/page/{pageNumber}")]
        public async Task<IActionResult> Get(int pageNumber, [FromQuery] FilterByCollectionParams filter)
        {
            try
            {
                List<Post>? getPostsByFoodCollection = null;
                if (filter.Collection != null)
                {
                    var collection = await _repoManager.Collection.GetCollectionByNameAsync(filter.Collection);
                    if (collection == null)
                    {
                        return BadRequest(new Response(400, "Not found collection"));
                    }
                    var foodCollections = await _repoManager.FoodCollection.GetFoodCollectionsAsync(collection.Id);
                    getPostsByFoodCollection = _repoManager.Post.GetPostByFoodCollection(foodCollections);
                }

                var posts = _repoManager.Post.GetPostFilter(getPostsByFoodCollection, filter.Search);
                var showPosts = _mapper.Map<List<ShowPostDTO>>(posts);
                for (int i = 0; i < showPosts.Count; i++)
                {
                    showPosts[i] = await _servicesManager.PostService.GetPostInfo(showPosts[i]);
                }

                if (filter.Sort != null)
                {
                    showPosts = _repoManager.Post.SortPostByCondition(showPosts, filter.Sort);
                }

                var result = PaginatedList<ShowPostDTO>.Create(showPosts, pageNumber, filter.PageSize);
                return Ok(new Response(200, result, "", result.Meta));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(500, ex.Message));
            }
        }
    }
}
