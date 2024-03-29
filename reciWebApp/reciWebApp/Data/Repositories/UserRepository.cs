﻿using Microsoft.EntityFrameworkCore;
using reciWebApp.Data.IRepositories;
using reciWebApp.Data.Models;
using reciWebApp.Data.Repositories.Extensions;
using reciWebApp.DTOs;
using reciWebApp.DTOs.UserDTOs;
using reciWebApp.Services.Commons;

namespace reciWebApp.Data.Repositories
{
    public class UserRepository : RepositoryBase<User>, IUserRepository
    {
        public UserRepository(ReciContext reciContext) : base(reciContext)
        {
        }

        public async Task<User> GetUserByEmailAsync(string email)
        {
            return await GetByCondition(x => x.Email == email).SingleOrDefaultAsync();
        }

        public void CreateUser(User user)
        {
            Create(user);
        }

        public async Task<User?> GetUserByIdAsync(int id)
        {
            return await GetByCondition(x => x.Id == id).SingleOrDefaultAsync();
        }

        public User? GetUserById(int id)
        {
            return GetByCondition(x => x.Id == id).FirstOrDefault();
        }

        public User? GetUserByEmail(string email)
        {
            return GetByCondition(x => x.Email == email).FirstOrDefault();
        }
        public List<User> GetAllUser()
        {
            return GetAll().ToList();
        }
        public async Task<List<User>?> GetAllUserAsync(UserParams userParams)
        {
            return await GetAll().FilterUserByName(_reciContext, userParams.Name).FilterUserByStatus(_reciContext, userParams.Status).ToListAsync();
        }
        public async Task<List<User>>? SearchUserAsync (string search)
        {
            return await GetByCondition(x => x.Name.Contains(search) || x.Email.Contains(search)).ToListAsync();
        }
        public List<User> SearchUser (string search)
        {
            return GetByCondition(x => x.Name.Contains(search) || x.Email.Contains(search)).ToList();
        }

        public async Task<int> TotalAccountsAsync()
        {
            return await GetByCondition(x => x.Role == RoleTypes.User).CountAsync();
        }

        public IQueryable<TopUserHighRating> GetTopUserHighRatings(int topNumber, IQueryable<UserInteract> userInteracts, IQueryable<Post> posts)
        {
            var topRatings = userInteracts.Where(x => x.Rating != null).GroupBy(x => x.PostsId, r => r.Rating)
                                                                       .Select(x => new
                                                                       {
                                                                           PostId = x.Key,
                                                                           AvgRating = x.Average()
                                                                       });

            var avgRatingOfPosts = topRatings.Join(posts,
                                                    topRating => topRating.PostId, post => post.Id,
                                                    (topRating, post) => new
                                                    {
                                                        UserId = post.UserId,
                                                        AvgRating = topRating.AvgRating
                                                    });

            var avgRatingsOfUsers = avgRatingOfPosts.GroupBy(x => x.UserId, r => r.AvgRating)
                                                    .Select(x => new
                                                    {
                                                        UserId = x.Key,
                                                        AvgRating = x.Average()
                                                    });

            var topUserHighRating = avgRatingsOfUsers.Join(GetAll(),
                                                        avgRatingOfUser => avgRatingOfUser.UserId, allUser => allUser.Id,
                                                        (avgRatingOfUser, allUser) => new TopUserHighRating
                                                        {
                                                            Name = allUser.Name,
                                                            Average = Math.Round((decimal)avgRatingOfUser.AvgRating)
                                                        })
                                                        .OrderByDescending(x => x.Average)
                                                        .Take(topNumber);
            return topUserHighRating;
        }

        public IQueryable<TopUserMostPosts> GetTopUserMostPost(IQueryable<GetTopUserHaveMostPost> posts)
        {
            var topUserMostPost = GetAll().Join(posts,
                                                user => user.Id, post => post.UserId,
                                                (user, post) => new TopUserMostPosts
                                                {
                                                    Name = user.Name,
                                                    TotalPost = post.TotalPost
                                                })
                                                .OrderByDescending(x => x.TotalPost);
            return topUserMostPost;
        }
    }
}
    