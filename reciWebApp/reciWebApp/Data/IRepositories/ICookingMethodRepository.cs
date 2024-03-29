﻿using reciWebApp.Data.Models;

namespace reciWebApp.Data.IRepositories
{
    public interface ICookingMethodRepository
    {
        void CreateCookingMethod(CookingMethod cookingMethod);
        void UpdateCookingMethod(CookingMethod cookingMethod);  
        void DeleteCookingMethod(CookingMethod cookingMethod);
        Task<List<CookingMethod>?> GetAllCookingMethodsAsync();
        CookingMethod? GetCookingMethodById(int id);
        List<CookingMethod> GetCookingMethodsByName(List<string>? names);
        CookingMethod GetCookingMethodByNameSignle(string name);
    }
}
